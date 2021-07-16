import httpclient, json, random, cligen, os

proc rwp(subs:seq[string]= @["wallpaper", "HI_Res", "MinimalWallpaper"],
         usenitrogen:bool=true):int=
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

  os.createDir("wp")

  var selurl = sample(candidates)
  var filename = selurl.split("/")[selurl.split("/").len - 1]
  client.downloadFile(selurl, "wp/" & filename)

  if usenitrogen:
    discard execShellCmd("nitrogen --set-zoom-fill wp/" & filename)

  result = 1

dispatch(rwp)