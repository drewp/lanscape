import ast
import requests


def ingestNtop():
    resp = requests.get('http://10.5.0.1:3000/lua/local/lanscape/main.lua')
    byMac = {}
    for line in resp.text.splitlines(keepends=False):
        if not line.strip():
            continue
        first, value = line.rsplit(' ', 1)
        metric, rest = first.split('{')
        labels, _ = rest.split('}')
        ld = {}
        for label in labels.split(','):
            k, v = label.split('=', 1)
            ld[k] = ast.literal_eval(v)
        if metric == 'hosts_count':
            pass
        elif metric == 'host_names':
            for k, v in ld.items():
                byMac.setdefault(ld['mac'], {})[k] = v
        else:
            byMac.setdefault(ld['mac'], {})[metric] = float(value)

    return (byMac)
