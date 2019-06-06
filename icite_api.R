library(httr)

ua <- user_agent('http://github.com/riddlet')

icite_api <- function(pmid) {
  pth <- paste('api/pubs/', pmid, sep='')
  url <- modify_url('https://icite.od.nih.gov/', path=pth)
  resp <- GET(url, ua)
  if(http_type(resp) != 'application/json'){
    stop('API did not return json.', call. = FALSE)
  }
  parsed <- jsonlite::fromJSON(content(resp, 'text'), simplifyVector=FALSE)
  
  if (http_error(resp)) {
    stop(
      sprintf(
        "iCite API request failed [%s]\n%s", 
        status_code(resp),
        parsed$error
      ),
      call. = FALSE
    )
  }
  
  structure(
    list(
      content = parsed,
      path = pth,
      response = resp
    ),
    class='icite_api'
  )
}

print.icite_api <- function(x, ...) {
  cat('<iCite ', x$path, '>\n', sep='')
  str(x$content)
  invisible(x)
}

to_dataframe <- function(info, error = F){
  if(error==F){
    parsed <- info$content
    out <- data.frame(pmid = parsed$pmid,
                      doi = parsed$doi,
                      authors = parsed$authors,
                      citation_count = parsed$citation_count,
                      citations_per_year = parsed$citations_per_year,
                      expected_citations_per_year = parsed$expected_citations_per_year,
                      field_citation_rate = parsed$field_citation_rate,
                      is_research_article = parsed$is_research_article,
                      journal = parsed$journal,
                      nih_percentile = parsed$nih_percentile,
                      relative_citation_ratio = parsed$relative_citation_ratio,
                      title = parsed$title,
                      year = parsed$year)
    return(out)
  }
  if(error==T){
    out <- data.frame(pmid = info,
                      doi = NA,
                      authors = NA,
                      citation_count = NA,
                      citations_per_year = NA,
                      expected_citations_per_year = NA,
                      field_citation_rate = NA,
                      is_research_article = NA,
                      journal = NA,
                      nih_percentile = NA,
                      relative_citation_ratio = NA,
                      title = NA,
                      year = NA)
  }
  
}

get_metrics <- function(pmids){
  df <- data.frame(pmid=pmids)
  tempdat <- data.frame()
  for(i in pmids){
    out <- tryCatch({
      to_dataframe(icite_api(i))
    },
    error = function(err) {
      return(to_dataframe(i, error=T))
    })
    tempdat <- rbind(tempdat, out)
    Sys.sleep(.1)
  }
  return(tempdat)
}

to_dataframe(icite_api('23456789'))
content(resp)

get_metrics(c('23456789', '26011165'))

