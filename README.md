getAfraidOrgDomains
===================

Script to update your proxies or spam engines blacklist from "afraid.org".

This script extract all the public and private domains from 'araid.org' and save them in results folder to feed your spam 
or proxy rules.

Those subdomains are frecuently used to host phishing campaings and malware distribution, as anyone can create a subdomain
of a free domain sometimes wihout the legitimate owner of the domain knowledge.

Just configure the number of pages present in the list of domains of https://freedns.afraid.org/domain/registry/ 
(currently 1005 pages) and pass this number as the first argument of the script. Default value is (1005).

