import httpclient, json, random, cligen, os, strutils, algorithm, times

proc rwp(subs:seq[string]= @["wallpaper", "HI_Res", "MinimalWallpaper"],
         wpcommand:string="nitrogen --set-zoom-fill %p",
         wpfoldername:string="wp",
         maxfilesinwp:int=5):int=
  var client = newHttpClient()
  var candidates: seq[string] 

  for sub in subs:
    echo("getting: " & sub)
    var raw: string = client.getContent("https://old.reddit.com/r/" & sub & "/random.json")
    let jsonNode = parseJson(raw)
    var imgurl = jsonNode[0]["data"]["children"][0]["data"]["url"].to(string)
    echo(imgurl)
    if (imgurl.contains("jpg") or imgurl.contains("png")):
      candidates.add(imgurl)

  createDir(wpfoldername)
  var files: seq[(string, FileInfo)]
  for kind, path in walkDir(wpfoldername):
    files.add((path, getFileInfo(path)))

  proc filedatecmp(x:(string, FileInfo), y: (string, FileInfo)):int =
    if x[1].lastWriteTime > y[1].lastWriteTime: return -1
    elif x[1].lastWriteTime == y[1].lastWriteTime: return 0
    else: 1

  files.sort(filedatecmp)
  echo("oldest file: " & files[files.len - 1][0])
  echo("amount of files: " & $files.len)
  if files.len > maxfilesinwp:
    for i in 0..(files.len - maxfilesinwp):
      echo("removing file: " & files[files.len - 1][0])
      removeFile(files[files.len - 1][0])
      files.delete(files.len - 1);

  var selurl = sample(candidates)
  var filename = selurl.split("/")[selurl.split("/").len - 1]
  client.downloadFile(selurl, wpfoldername & "/" & filename)

  discard execShellCmd(wpcommand.replace("%p", "wp/" & filename))

  result = 1

dispatch(rwp)