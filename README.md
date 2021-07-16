Run ntop and arrange for the files in ntopng-plugin to be found at 
`/usr/share/ntopng/scripts/lua/local/lanscape/`

You can now have prometheus scrape `/lua/local/lanscape/main.lua` (relative to your ntopng root URL). This tool also fetches that page.

Then, run the lanscape GUI from this dir with skaffold. Route a URL to port 8001 to see the lanscape GUI.

netdevices.n3 looks like this:
```
@prefix rdfs: <http://www.w3.org/2000/01/rdf-schema#> .
@prefix hs: <http://bigasterisk.com/hostStatus/> .

<http://bigasterisk.com/mac/00:01:02:a3:a4:a5> rdfs:label "some cool name" .
...

```