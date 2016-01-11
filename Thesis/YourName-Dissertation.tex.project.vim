" ATP project vim script: Tue Dec 29, 2015 at 12:31 PM +0100.

let b:atp_MainFile = 'YourName-Dissertation.tex'
let g:atp_mapNn = 0
let b:atp_autex = 1
let b:atp_TexCompiler = 'pdflatex'
let b:atp_TexOptions = '-synctex=1'
let b:atp_TexFlavor = 'tex'
let b:atp_auruns = '1'
let b:atp_ReloadOnError = '1'
let b:atp_OutDir = '/Users/subramanya/Downloads/PSUThesis'
let b:atp_OpenViewer = '1'
let b:atp_XpdfServer = 'YourName-Dissertation'
let b:atp_Viewer = 'open'
let b:TreeOfFiles = {'Chapter-5/Chapter-5.tex': [{}, 463], 'Chapter-1/Chapter-1.tex': [{}, 459], 'Chapter-2/Chapter-2.tex': [{}, 460], 'Chapter-4/Chapter-4.tex': [{}, 462], 'Appendix-D/Appendix-D.tex': [{}, 482], 'Appendix-C/Appendix-C.tex': [{}, 481], 'Appendix-A/Appendix-A.tex': [{}, 479], 'Appendix-B/Appendix-B.tex': [{}, 480], 'Chapter-3/Chapter-3.tex': [{}, 461]}
let b:ListOfFiles = ['SupplementaryMaterial/UserDefinedCommands.tex', 'Chapter-1/Chapter-1.tex', 'Chapter-2/Chapter-2.tex', 'Chapter-3/Chapter-3.tex', 'Chapter-4/Chapter-4.tex', 'Chapter-5/Chapter-5.tex', 'Appendix-A/Appendix-A.tex', 'Appendix-B/Appendix-B.tex', 'Appendix-C/Appendix-C.tex', 'Appendix-D/Appendix-D.tex', 'Biblio-Database.bib']
let b:TypeDict = {'Chapter-5/Chapter-5.tex': 'input', 'Chapter-1/Chapter-1.tex': 'input', 'Chapter-2/Chapter-2.tex': 'input', 'Biblio-Database.bib': 'bib', 'Chapter-4/Chapter-4.tex': 'input', 'Appendix-D/Appendix-D.tex': 'input', 'Appendix-C/Appendix-C.tex': 'input', 'Appendix-A/Appendix-A.tex': 'input', 'Appendix-B/Appendix-B.tex': 'input', 'Chapter-3/Chapter-3.tex': 'input', 'SupplementaryMaterial/UserDefinedCommands.tex': 'preambule'}
let b:LevelDict = {'Chapter-5/Chapter-5.tex': 1, 'Chapter-1/Chapter-1.tex': 1, 'Chapter-2/Chapter-2.tex': 1, 'Biblio-Database.bib': 1, 'Chapter-4/Chapter-4.tex': 1, 'Appendix-D/Appendix-D.tex': 1, 'Appendix-C/Appendix-C.tex': 1, 'Appendix-A/Appendix-A.tex': 1, 'Appendix-B/Appendix-B.tex': 1, 'Chapter-3/Chapter-3.tex': 1, 'SupplementaryMaterial/UserDefinedCommands.tex': 1}
let b:atp_BibCompiler = 'bibtex'
let b:atp_StarEnvDefault = ''
let b:atp_StarMathEnvDefault = ''
let b:atp_updatetime_insert = 4000
let b:atp_updatetime_normal = 2000
let b:atp_LocalCommands = ['\hsp']
let b:atp_LocalEnvironments = []
let b:atp_LocalColors = ['gray75']
