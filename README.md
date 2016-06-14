# {mscstexta4r}
Phil Ferriere  
June 2016  

[![Build Status](https://api.travis-ci.org/philferriere/mscstexta4r.png)](https://travis-ci.org/philferriere/mscstexta4r)
[![codecov.io](https://codecov.io/github/philferriere/mscstexta4r/coverage.svg?branch=master)](https://codecov.io/github/philferriere/mscstexta4r?branch=master)

[Microsoft Cognitive Services](https://www.microsoft.com/cognitive-services/en-us/documentation)
-- formerly known as Project Oxford -- are a set of APIs, SDKs and services
that developers can use to add [AI](https://en.wikipedia.org/wiki/Artificial_intelligence)
features to their apps. Those features include emotion and video detection;
facial, speech and vision recognition; and speech and natural language
processing ([NLP](https://en.wikipedia.org/wiki/Natural_language_processing)).

> Note: A test/demo Shiny web application is available [here](https://github.com/philferriere/mscsshiny).

## What's the Text Analytics REST API?

Per Microsoft's website, the [Text Analytics REST API](https://www.microsoft.com/cognitive-services/en-us/text-analytics/documentation)
is a suite of text analytics web services built with Azure Machine Learning that
can be used to analyze unstructured text. The API supports four text analysis
operations:

* Sentiment analysis - Is a sentence or document generally positive or negative?
* Topic detection - What's being discussed across a list of documents/reviews/articles?
* Language detection - What language is a document written in?
* Key talking points extraction - What's being discussed in a single document?

### Sentiment analysis

The API returns a numeric score between 0 and 1. Scores close to 1 indicate
positive sentiment and scores close to 0 indicate negative sentiment. Sentiment
score is generated using classification techniques. The input features of the
classifier include n-grams, features generated from part-of-speech tags, and
word embeddings. English, French, Spanish and Portuguese text are supported.

### Topic detection

This API returns the detected topics for a list of submitted text records. A
topic is identified with a key phrase, which can be one or more related words.
This API requires a minimum of 100 text records to be submitted, but is designed
to detect topics across hundreds to thousands of records. The API is designed to
work well for short, human-written text such as reviews and user feedback.

### Language detection

This API returns the detected language and a numeric score between 0 and 1.
Scores close to 1 indicate 100% certainty that the identified language is
correct. A total of 120 languages are supported.

### Extraction of key talking points

This API returns a list of strings denoting the key talking points in the input
text. English, German, Spanish, and Japanese text are supported.

To use the `{mscstexta4r}` R package, you **MUST** have a valid [account](https://www.microsoft.com/cognitive-services/en-us/pricing)
with Microsoft Cognitive Services. Once you have an account, Microsoft will
provide you with an [API key](https://en.wikipedia.org/wiki/Application_programming_interface_key).
This key will be listed under your subscriptions.

After you've configured `{mscstexta4r}` with your API key, you will be able to
call the Text Analytics REST API from R, up to your maximum number of
transactions per month and per minute.

## Package Installation

You can either install the latest **stable** version from CRAN:


```r
if ("mscstexta4r" %in% installed.packages()[,"Package"] == FALSE) {
  install.packages("mscstexta4r")
}
```

Or, you can install the **development** version


```r
if ("mscstexta4r" %in% installed.packages()[,"Package"] == FALSE) {
  if ("devtools" %in% installed.packages()[,"Package"] == FALSE) {
    install.packages("devtools")
  }
  devtools::install_github("philferriere/mscstexta4r")
}
```

## Package Loading and Configuration

After loading `{mscstexta4r}` with `library()`, you **must** call `textaInit()`
before you can call any of the core `{mscstexta4r}` functions.

The `textaInit()` configuration function will first check to see if the variable
`MSCS_TEXTANALYTICS_CONFIG_FILE` exists in the system environment. If it does,
the package will use that as the path to the configuration file.

If `MSCS_TEXTANALYTICS_CONFIG_FILE` doesn't exist, it will look for the file
`.mscskeys.json` in the current user's home directory (that's `~/.mscskeys.json`
on Linux, and something like `C:\Users\Phil\Documents\.mscskeys.json` on
Windows). If the file is found, the package will load the API key and URL from
it.

If using a file, please make sure it has the following structure:

```json
{
  "textanalyticsurl": "https://westus.api.cognitive.microsoft.com/texta/analytics/v2.0/",
  "textanalyticskey": "...MSCS Text Analytics API key goes here..."
}
```

If no configuration file is found, `textaInit()` will attempt to pick up its
configuration from two Sys env variables instead:

`MSCS_TEXTANALYTICS_URL` - the URL for the Text Analytics REST API.

`MSCS_TEXTANALYTICS_KEY` - your personal Text Analytics REST API key.

`textaInit()` needs to be called *only once*, after package load.

## Error Handling

The MSCS Text Analytics API is a **[RESTful](https://en.wikipedia.org/wiki/Representational_state_transfer)** API.
HTTP requests over a network and the Internet can fail. Because of congestion,
because the web site is down for maintenance, because of firewall configuration
issues, etc. There are many possible points of failure.

The API can also fail if you've **exhausted your call volume quota** or are
**exceeding the API calls rate limit**. Unfortunately, MSCS does not expose an
API you can query to check if you're about to exceed your quota for instance.
The only way you'll know for sure is by **looking at the error code** returned
after an API call has failed.

To help with error handling, we recommend the systematic use of `tryCatch()`
when calling `{mscstexta4r}` core functions. Its mechanism may appear a bit
daunting at first, but it is well [documented](http://www.inside-r.org/r-doc/base/signalCondition).
We've also included many examples, as you'll see below.

## Synchronous vs Asynchronous Execution

All but **one** core text analytics functions execute exclusively in synchronous
mode. `textaDetectTopics()` is the only function that can be executed either
synchronously or asynchronously. Why? Because topic detection is typically a
"batch" operation meant to be performed on thousands of related documents
(product reviews, research articles, etc.).

### What's the Difference?

When `textaDetectTopics()` executes synchronously, you must wait for it to
finish before you can move on to the next task. When `textaDetectTopics()`
executes asynchronously, you can move on to something else before topic
detection has completed. In the latter case, you will need to call
`textaDetectTopicsStatus()` periodically yourself until the Microsoft Cognitive
Services server complete topic detection and results become available.

### When to Run Which Mode

If you're performing topic detection in batch mode (from an R script), we
recommend using the `textaDetectTopics()` in synchronous mode, in which case,
again, it will return only after topic detection has completed.

If you're calling `textaDetectTopics()` in synchronous mode within the R console
REPL (interactive mode), it will **appear as if the console has hanged**. This
is *EXPECTED*. The function hasn't crashed. It is simply in "sleep mode",
activating itself periodically and then going back to sleep, until the results
have become available. In sleep mode, even though it appears "stuck",
`textaDetectTopics()` doesn't use any CPU resources. While the function is
operating in sleep mode, you *WILL NOT* be able to use the console before the
function completes. If you need to operate the console while topic detection is
being performed by the Microsoft Cognitive services servers, you should call
`textaDetectTopics()` in asynchronous mode and then call
`textaDetectTopicsStatus()` yourself repeatedly afterwards, until results are
available.

## Package Configuration with Error Handling

Here's some sample code that illustrates how to use `tryCatch()`:


```r
library('mscstexta4r')
tryCatch({

  textaInit()

}, error = function(err) {

  geterrmessage()

})
```

If `{mscstexta4r}` cannot locate `.mscskeys.json` nor any of the configuration
environment variables, the code above will generate the following output:


```r
[1] "mscstexta4r: could not load config info from Sys env nor from file"
```

Similarly, `textaInit()` will fail if `{mscstexta4r}` cannot find the
`textanalyticskey` key in `.mscskeys.json`, or fails to parse it correctly,
etc. This is why it is so important to use `tryCatch()` with all `{mscstexta4r}`
functions.

## Package API

The core API calls exposed by `{mscstexta4r}` are the following:


```r
# Perform sentiment analysis
textaSentiment(
  documents,                  # Input sentences or documents
  languages = rep("en", length(documents))
  # "en"(English, default)|"es"(Spanish)|"fr"(French)|"pt"(Portuguese)
)
```


```r
# Detect top topics in group of documents
textaDetectTopics(
  documents,                  # At least 100 documents
  stopWords = NULL,           # Stop word list (optional)
  topicsToExclude = NULL,     # Topics to exclude (optional)
  minDocumentsPerWord = NULL, # Threshold to exclude rare topics (optional)
  maxDocumentsPerWord = NULL, # Threshold to exclude ubiquitous topics (optional)
  resultsPollInterval = 30L,  # Poll interval (in s, default: 30s, use 0L for async)
  resultsTimeout = 1200L,     # Give up timeout (in s, default: 1200s = 20mn)
  verbose = FALSE             # If set to TRUE, print every poll status to stdout
)
```


```r
# Detect languages used in documents
textaDetectLanguages(
  documents,                      # Input sentences or documents
  numberOfLanguagesToDetect = 1L  # Default: 1L
)
```


```r
  # Get key talking points in documents
textaKeyPhrases(
  documents,                  # Input sentences or documents
  languages = rep("en", length(documents))
  # "en"(English, default)|"de"(German)|"es"(Spanish)|"fr"(French)|"ja"(Japanese)
)
```

The functions `textaDetectTopics()` returns a S3 class object of the class
`textatopics`. The `textatopics` object exposes formatted results using several
dataframes (documents and their IDs, topics and their IDs, which topics are
assigned to which documents), the REST API JSON response (should you care),
and the HTTP request (mostly for debugging purposes).

The other functions return S3 class objects of the class `texta`. The `texta`
object exposes results collected in a single `data.frame`, the REST API JSON
response, and the original HTTP request.

## Sample Code

The following code snippets illustrate how to use {mscstexta4r} functions and
show what results they return with toy examples. If after reviewing this code
there is still confusion regarding how and when to use each function, please
refer to the [original documentation](https://www.microsoft.com/cognitive-services/en-us/text-analytics/documentation).

### Sentiment Analysis


```r
docsText <- c(
  "Loved the food, service and atmosphere! We'll definitely be back.",
  "Very good food, reasonable prices, excellent service.",
  "It was a great restaurant.",
  "If steak is what you want, this is the place.",
  "The atmosphere is pretty bad but the food is quite good.",
  "The food is quite good but the atmosphere is pretty bad.",
  "The food wasn't very good.",
  "I'm not sure I would come back to this restaurant.",
  "While the food was good the service was a disappointment.",
  "I was very disappointed with both the service and my entree."
)
docsLanguage <- rep("en", length(docsText))

tryCatch({

  # Perform sentiment analysis
  textaSentiment(
    documents = docsText,    # Input sentences or documents
    languages = docsLanguage
    # "en"(English, default)|"es"(Spanish)|"fr"(French)|"pt"(Portuguese)
)

}, error = function(err) {

  # Print error
  geterrmessage()

})
#> texta [https://westus.api.cognitive.microsoft.com/text/analytics/v2.0/sentiment]
#> 
#> --------------------------------------
#>              text               score 
#> ------------------------------ -------
#>  Loved the food, service and   0.9847 
#>  atmosphere! We'll definitely         
#>            be back.                   
#> 
#>   Very good food, reasonable   0.9831 
#>   prices, excellent service.          
#> 
#>   It was a great restaurant.   0.9306 
#> 
#>   If steak is what you want,   0.8014 
#>       this is the place.              
#> 
#>  The atmosphere is pretty bad  0.4998 
#>  but the food is quite good.          
#> 
#> The food is quite good but the  0.475 
#>   atmosphere is pretty bad.           
#> 
#>   The food wasn't very good.   0.1877 
#> 
#> I'm not sure I would come back 0.2857 
#>      to this restaurant.              
#> 
#>  While the food was good the   0.08727
#> service was a disappointment.         
#> 
#>  I was very disappointed with  0.01877
#>    both the service and my            
#>            entree.                    
#> --------------------------------------
```

### Topic Detection (synchronous mode)


```r
# Load yelpChReviews100 text reviews
load("./tests/testthat/data/yelpChineseRestaurantReviews100.rda")

tryCatch({

  # Detect top topics
  textaDetectTopics(
    documents = yelpChReviews100, # At least 100 docs/sentences
    stopWords = NULL,             # Stop word list (optional)
    topicsToExclude = NULL,       # Topics to exclude (optional)
    minDocumentsPerWord = NULL,   # Threshold to exclude rare topics (optional)
    maxDocumentsPerWord = NULL,   # Threshold to exclude ubiquitous topics (optional)
    resultsPollInterval = 30L,    # Poll interval (in s, default: 30s, use 0L for async)
    resultsTimeout = 1200L,       # Give up timeout (in s, default: 1200s = 20mn)
    verbose = FALSE               # If set to TRUE, print every poll status to stdout
  )

}, error = function(err) {

  # Print error
  geterrmessage()

})
#> textatopics [https://westus.api.cognitive.microsoft.com/text/analytics/v2.0/topics?]
#> status: Succeeded
#> operationId: add4d82003c84da897975f24f19a2698
#> operationType: topics
#> topics (first 20):
#> 
#> -------------------
#>  keyPhrase   score 
#> ----------- -------
#>    soup       19   
#> 
#>    beef       10   
#> 
#>    curry       8   
#> 
#>     egg        7   
#> 
#>   flavor       7   
#> 
#>    pork        7   
#> 
#>    China       6   
#> 
#>    roll        6   
#> 
#>   people       5   
#> 
#>   review       5   
#> 
#>   wontons      5   
#> 
#>    sushi       5   
#> 
#>  delivery      5   
#> 
#>    town        4   
#> 
#>   Phoenix      4   
#> 
#>    rolls       4   
#> 
#>   couple       4   
#> 
#>   tables       4   
#> 
#>   Buffet       4   
#> 
#>    yelp        3   
#> -------------------
```

### Topic Detection (asynchronous mode)


```r
# Load yelpChReviews100 text reviews
load("./tests/testthat/data/yelpChineseRestaurantReviews100.rda")

tryCatch({

  # Detect top topics
  operation <- textaDetectTopics(
    documents = yelpChReviews100, # At least 100 docs/sentences
    resultsPollInterval = 0L      # Poll interval (in s, default: 30s, use 0L for async)
  )

  # Poll the servers ourselves, until the work completes or until we time out
  resultsPollInterval <- 30L
  resultsTimeout <- 1200L
  startTime <- Sys.time()
  endTime <- startTime + resultsTimeout

  while (Sys.time() <= endTime) {
    sleepTime <- startTime + resultsPollInterval - Sys.time()
    if (sleepTime > 0)
      Sys.sleep(sleepTime)
    startTime <- Sys.time()

    # Poll for results
    topics <- textaDetectTopicsStatus(operation)
    if (topics$status != "NotStarted" && topics$status != "Running")
      break;
  }

  topics

}, error = function(err) {

  # Print error
  geterrmessage()

})
#> textatopics [https://westus.api.cognitive.microsoft.com/text/analytics/v2.0/topics?]
#> status: Succeeded
#> operationId: b1c3a97a48bc43898d417c6d57ec8706
#> operationType: topics
#> topics (first 20):
#> 
#> -------------------
#>  keyPhrase   score 
#> ----------- -------
#>    soup       19   
#> 
#>    beef       10   
#> 
#>    curry       8   
#> 
#>     egg        7   
#> 
#>   flavor       7   
#> 
#>    pork        7   
#> 
#>    China       6   
#> 
#>    roll        6   
#> 
#>   people       5   
#> 
#>   review       5   
#> 
#>   wontons      5   
#> 
#>    sushi       5   
#> 
#>  delivery      5   
#> 
#>    town        4   
#> 
#>   Phoenix      4   
#> 
#>    rolls       4   
#> 
#>   couple       4   
#> 
#>   tables       4   
#> 
#>   Buffet       4   
#> 
#>    yelp        3   
#> -------------------
```

### Language Detection


```r
docsText = c(
  "The Louvre or the Louvre Museum is the world's largest museum.",
  "Le musée du Louvre est un musée d'art et d'antiquités situé au centre de Paris.",
  "El Museo del Louvre es el museo nacional de Francia.",
  "Il Museo del Louvre a Parigi, in Francia, è uno dei più celebri musei del mondo.",
  "Der Louvre ist ein Museum in Paris."
)

tryCatch({

  # Detect languages
  textaDetectLanguages(
    documents = docsText,           # Input sentences or documents
    numberOfLanguagesToDetect = 1L  # Number of languages to detect
  )

}, error = function(err) {

  # Print error
  geterrmessage()

})
#> texta [https://westus.api.cognitive.microsoft.com/text/analytics/v2.0/languages?numberOfLanguagesToDetect=1]
#> 
#> -----------------------------------------------------------
#>             text               name    iso6391Name   score 
#> ----------------------------- ------- ------------- -------
#>   The Louvre or the Louvre    English      en          1   
#> Museum is the world's largest                              
#>            museum.                                         
#> 
#>   Le musée du Louvre est un   French       fr          1   
#>  musée d'art et d'antiquités                               
#>   situé au centre de Paris.                                
#> 
#>   El Museo del Louvre es el   Spanish      es          1   
#>  museo nacional de Francia.                                
#> 
#> Il Museo del Louvre a Parigi, Italian      it          1   
#>   in Francia, è uno dei più                                
#>   celebri musei del mondo.                                 
#> 
#> Der Louvre ist ein Museum in  German       de          1   
#>            Paris.                                          
#> -----------------------------------------------------------
```

### Key Talking Points Extraction


```r
docsText <- c(
  "Loved the food, service and atmosphere! We'll definitely be back.",
  "Very good food, reasonable prices, excellent service.",
  "It was a great restaurant.",
  "If steak is what you want, this is the place.",
  "The atmosphere is pretty bad but the food is quite good.",
  "The food is quite good but the atmosphere is pretty bad.",
  "I'm not sure I would come back to this restaurant.",
  "The food wasn't very good.",
  "While the food was good the service was a disappointment.",
  "I was very disappointed with both the service and my entree."
)
docsLanguage <- rep("en", length(docsText))

tryCatch({

  # Get key talking points in documents
  textaKeyPhrases(
    documents = docsText,    # Input sentences or documents
    languages = docsLanguage
    # "en"(English, default)|"de"(German)|"es"(Spanish)|"fr"(French)|"ja"(Japanese)
  )

}, error = function(err) {

  # Print error
  geterrmessage()

})
#> texta [https://westus.api.cognitive.microsoft.com/text/analytics/v2.0/keyPhrases]
#> 
#> -----------------------------------------------------------
#>              text                       keyPhrases         
#> ------------------------------ ----------------------------
#>  Loved the food, service and    atmosphere, food, service  
#>  atmosphere! We'll definitely                              
#>            be back.                                        
#> 
#>   Very good food, reasonable   reasonable prices, good food
#>   prices, excellent service.                               
#> 
#>   It was a great restaurant.         great restaurant      
#> 
#>   If steak is what you want,           steak, place        
#>       this is the place.                                   
#> 
#>  The atmosphere is pretty bad        atmosphere, food      
#>  but the food is quite good.                               
#> 
#> The food is quite good but the       food, atmosphere      
#>   atmosphere is pretty bad.                                
#> 
#> I'm not sure I would come back          restaurant         
#>      to this restaurant.                                   
#> 
#>   The food wasn't very good.               food            
#> 
#>  While the food was good the          service, food        
#> service was a disappointment.                              
#> 
#>  I was very disappointed with        service, entree       
#>    both the service and my                                 
#>            entree.                                         
#> -----------------------------------------------------------
```

## Credits

All Microsoft Cognitive Services components are Copyright © Microsoft.

For great introductions to the underlying REST API, please refer to [this](https://azure.microsoft.com/en-us/documentation/articles/cognitive-services-text-analytics-quick-start/)
and [that](https://blogs.technet.microsoft.com/machinelearning/2015/04/08/introducing-text-analytics-in-the-azure-ml-marketplace/) link.

## Meta

This package is certainly functional. It's also the first time it is available
on CRAN. Therefore, if you observe unexpected behaviors (a.k.a. bugs), please be
kind enough to submit a bug report on GitHub (not via email) with a minimal
reproducible example [here](https://github.com/philferriere/mscstexta4r/issues).

License: MIT + [file](./LICENSE)

To retrieve `{mscstexta4r}` citation information, run `citation(package = 'mscstexta4r')`

This project is released with a [Contributor Code of Conduct](./CONDUCT.md). By
 participating in this project, you agree to abide by its terms.

## About the Author

For more info about the author of this R package, please visit:

[![https://www.linkedin.com/in/philferriere](https://dl.dropboxusercontent.com/u/5888080/LinkedInDevLead.png)](https://www.linkedin.com/in/philferriere)


