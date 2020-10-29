## Trusted Client

The challenge is login page where all logic is implemented on client side. (Which the title hints at)

Viewing the page source reveals a single huge obfuscated JavaScript function. (Not displayed here because it's really huge)
Luckily the browsers javascript console is all we need to remove this kind of obfuscation.
```
(function anonymous() {
    if (this.username.value == 'the_flag_is' && this.password.value == '247CTF{redacted}') {
        alert('Valid username and password!');
    } else {
        alert('Invalid username and password!');
    }
}
)
```
The flag can be read directly from the code here.