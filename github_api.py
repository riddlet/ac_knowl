

import requests
import json

import pprint

#
#   Notes:
#       THIS OBJECT DOES NOT COUNT REQ/MIN
#       Github limits API calls to 5000 / hr (~83/min)
#
#       I will try to count for each method the number of requests
#       but it will definitely be !unstable
#
class GithubAPI():

    # 2 requests
    def __init__(self, endpoint="", repo_name=None, acct_name=None):

        #if we already know the repo
        if repo_name is not None and acct_name is not None:
            endpoint = "https://api.github.com/repos/%s/%s" % (repo_name,acct_name)
        self.endpoint = endpoint

        #HTTP for the endpoint
        with requests.get(endpoint) as req:
            # status check
            if not req.ok:
                # raise Exception("bad_endpoint")
                self.exists = False
                return

            self.repo_json = json.loads(req.text or req.content)

        branches_endpoint = self.endpoint + "/branches"
        self.branches_dict = {}
        with requests.get(branches_endpoint) as branches_req:
            branches_json = json.loads(branches_req.text or branches_req.content)
            for branch in branches_json:
                self.branches_dict[branch["name"]] = branch["commit"]

        #self.master_branch_sha = self.branches_dict["master"]["sha"]
        #pprint.pprint(self.branches_dict["master"])

    def exists(self):
        return self.exists

    def get_master_filelist(self):
        return self.get_branch_filelist("master")

    # 2 requests
    def get_branch_filelist(self, branch):
        #TODO: this should check if 'truncated' flag is set
        # if it is set, we need to iterate through the top level directory, looking for trees
        # OR we can clone the repo and do it on our own FS

        #TODO: deal with trunk cases? (needs commit API to pull all commit hashes)
        if branch not in self.branches_dict.keys():
            raise KeyError("[GithubAPI] Branch %s not found" % branch)

        last_commit_sha = self.branches_dict[branch]["sha"]

        commit_endpoint = self.endpoint + "/commits/%s" % last_commit_sha
        with requests.get(commit_endpoint) as commit_req:
            commit_json = json.loads(commit_req.text or commit_req.content)
            tree_sha = commit_json["commit"]["tree"]["sha"]

        #Note: recursive get does not return file structure, encodes tree into filenames
        tree_endpoint = self.endpoint + "/git/trees/%s?recursive=1" % tree_sha
        filelist = []
        with requests.get(tree_endpoint) as tree_req:
            tree_json = json.loads(tree_req.text or tree_req.content)
            for treenode in tree_json["tree"]:
               filelist.append(treenode) 
        return filelist

if __name__ == "__main__":
    print("testing on our own repo")
    #gh_obj = GithubAPI(repo_name="django", acct_name="django")
    gh_obj = GithubAPI(repo_name="riddlet", acct_name="ac_knowl")
    pprint.pprint(gh_obj.get_master_filelist())

    try:
        gh_obj = GithubAPI(repo_name="django-FALSENAMETEST", acct_name="django")
    except:
        print("caught exception for bad repo names")



