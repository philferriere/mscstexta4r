I have read and agree to the CRAN policies at
http://cran.r-project.org/web/packages/policies.html

## R CMD check test environments
* local Windows 10 install, R version 3.3.0 (2016-05-03)
* on travis-ci: ubuntu (R:release and R:devel)
* on travis-ci: osx (R:release and R:devel)
* on win-builder: (R-devel and R-release)

## R CMD check test results on all environments but win-builder
R CMD check results
0 errors | 0 warnings | 0 notes

## R CMD check test results on win-builder
R CMD check results
0 errors | 0 warnings | 1 notes

* checking CRAN incoming feasibility ... NOTE
Maintainer: 'Phil Ferriere <pferriere@hotmail.com>'

Days since last update: 2

License components with restrictions and base license permitting such:
  MIT + file LICENSE
File 'LICENSE':
  YEAR: 2016
  COPYRIGHT HOLDER: Phil Ferriere

Possibly mis-spelled words in DESCRIPTION:
  API (4:14, 10:10, 13:33, 13:53)
  Analytics (3:59, 9:65)

* Per [Wikipedia](https://en.wikipedia.org/wiki/Application_programming_interface), we believe this spelling to be correct. Both mis-spelling notes are false positives.

R CMD check tests were run in all test environments listed at the top of this note.

Thank you for your help.

Regards,
Phil Ferriere <pferriere@hotmail.com>
