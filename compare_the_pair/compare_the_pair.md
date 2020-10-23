## Compare The Pair (Easy)

Compare the Pair is the first challenge that I wouldn't call completely trivial. It requires a little familiary with PHP or PHP based ctf challenges. The challenge page once again displays it's own source code.

```
 <?php
  require_once('flag.php');
  $password_hash = "0e902564435691274142490923013038";
  $salt = "f789bbc328a3d1a3";
  if(isset($_GET['password']) && md5($salt . $_GET['password']) == $password_hash){
    echo $flag;
  }
  echo highlight_file(__FILE__, true);
?>
```

Anyone who has every looked at PHP based ctf challenges will immerdiatly nottice the loose comparison with `==`. But in this case both sides are strings so how does this help? Looking at the md5 checksum you'll notice t starts with `0e` and is just contains numbers after that. That's intentional!
This string can also be interpreted as exponential notation for anumber (0*10^902564435691274142490923013038 = 0) and thats exactly what PHP does when this string is used with `==`. So to pass this check we only have to find a string that combined with the salt produces another md5 checksum thats interpreted as 0. 

Thats something than can easily be bruteforced within seconds. The string `abr1R` satisfies this condition.