import docopt

from twisted.internet import reactor
import cyclone.httpserver
import cyclone.web
from standardservice.logsetup import log, verboseLogging
from cycloneerr import PrettyErrorHandler
import ingest_ntop
import json
from rdflib import Namespace, Graph, RDFS

MAC = Namespace('http://bigasterisk.com/mac/')


class Report(PrettyErrorHandler, cyclone.web.RequestHandler):

    def get(self):
        cat_names = {}
        g = Graph()
        g.parse('/my/proj/homeauto/service/wifi/netdevices.n3', format='n3')
        for s, o in g.subject_objects(RDFS.label):
            cat_names[s] = str(o)
        byMac = ingest_ntop.ingestNtop()
        rows = []
        for row in byMac.values():
            row['cat_name'] = cat_names.get(MAC[row['mac'].lower()], row['mac'])
            rows.append(row)
        rows.sort(key=lambda row: row['cat_name'])
        json.dump(rows, self)


def main():
    args = docopt.docopt('''
Usage:
  lanscape.py [options]

Options:
  -v, --verbose  more logging
''')
    verboseLogging(args['--verbose'])

    class Application(cyclone.web.Application):

        def __init__(self):
            handlers = [
                (r"/()", cyclone.web.StaticFileHandler, {
                    'path': '.',
                    'default_filename': 'index.html'
                }),
                #(r'/lit/(.*)', cyclone.web.StaticFileHandler, {'path': 'node_modules/lit'}),
                (r"/report", Report),
            ]
            cyclone.web.Application.__init__(
                self,
                handlers,
                debug=args['--verbose'],
                template_path='.',
            )

    reactor.listenTCP(8001, Application(), interface='::')
    reactor.run()


if __name__ == '__main__':
    main()
