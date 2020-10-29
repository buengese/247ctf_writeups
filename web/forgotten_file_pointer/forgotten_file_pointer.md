## Forgotten File Pointer (Moderate)

This challenge is the first to be rated moderate. The website once again displays it's own source code.

```
 <?php
  $fp = fopen("/tmp/flag.txt", "r");
  if($_SERVER['REQUEST_METHOD'] === 'GET' && isset($_GET['include']) && strlen($_GET['include']) <= 10) {
    include($_GET['include']);
  }
  fclose($fp);
  echo highlight_file(__FILE__, true);
?>
```

The vulnerability here is clear we control what's passed to the php `include()` function via the include get parameter. This function is great because if what is included isn't php code it's just displayed in plain (you can test this by passing `/etc/group`). There is one problem however we constained to pasth <= 10 characters and `/tmp/flag.txt` is clearly 13 characters.

The name of this challenge allready hints at what to do. I have to admit despite understanding the hint immediatly it took me an embarrassingly long amount of time to find out that these are stored in `/dev/fd/`. Before this challenge I had never encountered this path. Importantly this path is only 8 characters so we can try 0 to 99. 
```
for i in $(seq 0 99); do curl -s https://https://0b04aadc78f1e1cb.247ctf.com/?include=/dev/fd/$i | grep 247; done 
```
File descriptor 10 gives the flag.