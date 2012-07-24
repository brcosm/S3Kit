S3Kit
=====

S3Kit is a collection of utilities that make it easier to access Amazon's S3 via their [REST API][s3_rest_api].  Currently, the main feature is a NSURLRequest subclass, BS3Request.  This class can be used in place of a standard NSURLRequest to do a lot of the work involved in formatting and signing various requests to the REST API.

## Installation Instructions ##

S3Kit is a static library and is best included as a sub-module of your app's Git repo.  More detailed instructions coming soon.

## Example Usage ##

Coming soon.  Basically, just initialize the request and plug it into a NSURLConnection.
I will be updating the header files with documentation, check out the tests for some examples of different inputs.

[s3_rest_api]:http://docs.amazonwebservices.com/AmazonS3/latest/API/APIRest.html
