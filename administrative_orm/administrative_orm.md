## Administrative ORM (Moderate)

I somewhat disagree on the difficulty classification for this challenge. While the ideas behind this challenge really aren't that hard to understand I still spent a lot more time on this challenge than on the other moderate challenges before I actually got it to work.

Once again the website displays it's own source.

```
import pymysql.cursors
import pymysql, os, bcrypt, debug
from flask import Flask, request
from secret import flag, secret_key, sql_user, sql_password, sql_database, sql_host

class ORM():
    def __init__(self):
        self.connection = pymysql.connect(host=sql_host, user=sql_user, password=sql_password, db=sql_database, cursorclass=pymysql.cursors.DictCursor)

    def update(self, sql, parameters):
        with self.connection.cursor() as cursor:
          cursor.execute(sql, parameters)
          self.connection.commit()

    def query(self, sql, parameters):
        with self.connection.cursor() as cursor:
          cursor.execute(sql, parameters)
          result = cursor.fetchone()
        return result

    def get_by_name(self, user):
        return self.query('select * from users where username=%s', user)

    def get_by_reset_code(self, reset_code):
        return self.query('select * from users where reset_code=%s', reset_code)

    def set_password(self, user, password):
        password_hash = bcrypt.hashpw(password, bcrypt.gensalt())
        self.update('update users set password=%s where username=%s', (password_hash, user))

    def set_reset_code(self, user):
        self.update('update users set reset_code=uuid() where username=%s', user)

app = Flask(__name__)
app.config['DEBUG'] = False
app.config['SECRET_KEY'] = secret_key
app.config['USER'] = 'admin'

@app.route("/get_flag")
def get_flag():
    user_row = app.config['ORM'].get_by_name(app.config['USER'])
    if bcrypt.checkpw(request.args.get('password','').encode('utf8'), user_row['password'].encode('utf8')):
        return flag
    return "Invalid password for %s!" % app.config['USER']

@app.route("/update_password")
def update_password():
    user_row = app.config['ORM'].get_by_reset_code(request.args.get('reset_code',''))
    if user_row:
        app.config['ORM'].set_password(app.config['USER'], request.args.get('password','').encode('utf8'))
        return "Password reset for %s!" % app.config['USER']
    app.config['ORM'].set_reset_code(app.config['USER'])
    return "Invalid reset code for %s!" % app.config['USER']

@app.route("/statistics") # TODO: remove statistics
def statistics():
    return debug.statistics()

@app.route('/')
def source():
    return "

%s

" % open(__file__).read()

@app.before_first_request
def before_first():
    app.config['ORM'] = ORM()
    app.config['ORM'].set_password(app.config['USER'], os.urandom(32).hex())

@app.errorhandler(Exception)
def error(error):
    return "Something went wrong!"

if __name__ == "__main__":
    app.run()
```

To read the flag need a password that is randomly generated on startup and is way to long to bruteforce. Seeing all that sql I first thought this is going to be an sql injection challenge but a quick google search revealed that despite the fact that it's not using parameterized queries, the way pymysql escapes parameters in `cursors.execute()` is considered safe.

That leaves only the password reset as target. Looking at the MySQL docs for `UUID()` you'll find out that the uuid is generated according to RFC4122. There is also this warning:
>Although UUID() values are intended to be unique, they are not necessarily unguessable or unpredictable. If unpredictability is required, UUID values should be generated some other way. 

That's a pretty strong indication that we have to guess the uuid. According to rfc we need a special timestamp counting Number of 100-nanosecond intervals since 1582-10-15 00:00:00.00 when the uuid was generated, the clock sequence, the mac address of the machine and version. So where do we get these?. The comment on the statistics endpoint already hints that might be important, and indeed it has everything we need.
```
Interface statistics:
eth0      Link encap:Ethernet  HWaddr 02:42:AC:11:00:08  
[...]

Database statistics:
	clock_sequence: 14942
	last_reset: 2020-10-27 14:59:51.102918
[...]
```
(One think that tripped me up here was the time stamp. When i initially ran this it only had 7 numbers behind the dot (and I might have counted only 6) so I thought it only had microsecond accuracy. When parsing it as microseconds and multiplying by 10 to get the intervals I couldn't get the correct uuid (because I was missing accuracy). I took me a long time to realize my mistake and correctly parse the timestamp as nanoseconds.)

Instead of implementing my own version for the uuid generation I decided to go with the one from mysql. I threw together a quick and dirty C program around the code in `my_uuid.c`. The code is also available in this repo. 

(If you are using this you'll have to manually convert te timestamp to ns (numpy.timestamp64() is a good choice for this and set the parameters in the code.)

Using the uuid I reset the password to 123456 and got the flag.