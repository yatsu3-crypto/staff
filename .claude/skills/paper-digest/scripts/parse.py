#!/usr/bin/env python3
"""efetch の XML を JSON（pmid/title/journal/year/edat/types/abstract/doi）に変換し、一覧を標準出力に出す。
使い方: parse.py <in.xml> <out.json> [full]   ("full" を付けると抄録も表示)"""
import sys, json, xml.etree.ElementTree as ET
src, dst = sys.argv[1], sys.argv[2]
full = len(sys.argv) > 3 and sys.argv[3] == "full"
root = ET.parse(src).getroot()
out = []
for a in root.findall(".//PubmedArticle"):
    art = a.find(".//Article")
    if art is None:
        continue
    t = art.find("ArticleTitle")
    title = "".join(t.itertext()) if t is not None else ""
    journal = art.findtext(".//Journal/ISOAbbreviation") or art.findtext(".//Journal/Title") or ""
    abst = " ".join("".join(x.itertext()) for x in art.findall(".//Abstract/AbstractText"))
    types = [p.text for p in art.findall(".//PublicationType")]
    d = a.find(".//PubMedPubDate[@PubStatus='entrez']")
    if d is None:
        d = a.find(".//PubMedPubDate[@PubStatus='pubmed']")
    edat = "%s-%s-%s" % (d.findtext("Year"), d.findtext("Month").zfill(2), d.findtext("Day").zfill(2)) if d is not None else ""
    year = art.findtext(".//JournalIssue/PubDate/Year") or art.findtext(".//JournalIssue/PubDate/MedlineDate", "")[:4]
    doi = ""
    for e in a.findall("./PubmedData/ArticleIdList/ArticleId"):
        if e.get("IdType") == "doi":
            doi = e.text
    out.append(dict(pmid=a.findtext(".//PMID"), title=title, journal=journal, year=year,
                    edat=edat, types=types, abstract=abst, doi=doi))
json.dump(out, open(dst, "w"), ensure_ascii=False, indent=1)
for r in out:
    ty = ";".join(x for x in r["types"] if x != "Journal Article")
    print("== %s | %s | %s | %s | %s" % (r["pmid"], r["edat"], r["journal"], r["year"], ty))
    print("   ", r["title"])
    if full:
        print("   ", r["abstract"] or "(no abstract)")
        print()
