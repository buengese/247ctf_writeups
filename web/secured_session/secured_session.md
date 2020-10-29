## Secured Session (Easy)

Secured session is an easy introductory challenge in the web category.

The challenge site is flask web app. When accessing it, it displays it's own source

```
import os
from flask import Flask, request, session
from flag import flag

app = Flask(__name__)
app.config['SECRET_KEY'] = os.urandom(24)

def secret_key_to_int(s):
    try:
        secret_key = int(s)
    except ValueError:
        secret_key = 0
    return secret_key

@app.route("/flag")
def index():
    secret_key = secret_key_to_int(request.args['secret_key']) if 'secret_key' in request.args else None
    session['flag'] = flag
    if secret_key == app.config['SECRET_KEY']:
      return session['flag']
    else:
      return "Incorrect secret key!"

@app.route('/')
def source():
    return "

%s

" % open(__file__).read()

if __name__ == "__main__":
    app.run()
```

Almost every here is fluff. The one important line here is
```
    session['flag'] = flag
```

The flag is stored in the session. Upon reading the Flask docs for session you'll notice. 

>Sessions in Flask are a way to store information about a specific user from one request to the next. They work by storing a cryptographically signed cookie on the users browser and decoding it on every request.

>The session object is NOT a secure way to store data. It's a base64 encoded string and can easily be decoded, thus not making it a secure way to save or access sensitive information.

Base64 decoding the session cookie gives the flag.
```
$ echo "eyJmbGFnIjp7IiBiIjoiTWpRM1ExUkdlMlJoT0RBM09UVm1PR0UxWTJGaU1tVXdNemRrTnpNNE5UZ3dOMkk1WVRreGZRPT0ifX0.X5bJ_g.ckPLJyBJlyaHXAkPKz_zQykD8HQ" | base64 -d
{"flag":{" b":"MjQ3Q1RGe2RhODA3OTVmOGE1Y2FiMmUwMzdkNzM4NTgwN2I5YTkxfQ=="}
$ echo "MjQ3Q1RGe2RhODA3OTVmOGE1Y2FiMmUwMzdkNzM4NTgwN2I5YTkxfQ==" | base64 -d
flag
```