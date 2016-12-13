# PyInstaller Docker Images

**cdrx/pyinstaller-linux** and **cdrx/pyinstaller-windows** are a pair of Docker containers to ease compiling Python applications to binaries / exe files.

Current PyInstaller version used: 3.2.

## Tags

`cdrx/pyinstaller-linux` and `cdrx/pyinstaller-windows` both have two tags, `:python2` and `:python3` which you can use depending on the requirements of your project. `:latest` points to `:python3`

The `:python2` tags run Python 2.7. The `:python3` tag on Linux runs Python 3.5. On Windows, `:python3` uses Python 3.4.4 as that is the most recent version that has an installer that runs under Wine. 

## Usage

There are two containers, one for Linux and one for Windows builds. The Windows builder runs Wine inside Ubuntu to emulate Windows in Docker.

To build your application, you need to mount your source code into the `/src/` volume.

The source code directory should have your `.spec` file that PyInstaller generates. If you don't have one, you'll need to run PyInstaller once locally to generate it.

If the `src` folder has a `requirements.txt` file, the packages will be installed into the environment before PyInstaller runs.

For example, in the folder that has your source code, `.spec` file and `requirements.txt`:

```
docker run -v "$(pwd):/src/" cdrx/pyinstaller-windows
```

will build your PyInstaller project into `dist/windows/`. The `.exe` file will have the same name as your `.spec` file.

```
docker run -v "$(pwd):/src/" cdrx/pyinstaller-linux
```

will build your PyInstaller project into `dist/linux/`. The binary will have the same name as your `.spec` file.

##### How do I install system libraries or dependencies that my Python packages need?

You'll need to supply a custom command to Docker to install system pacakges. Something like:

```
docker run -v "$(pwd):/src/" cdrx/pyinstaller-linux sh -c "apt-get update -y && apt-get install -y wget && pip install -r requirements.txt && pyinstaller --clean -y --dist ./dist/linux --workpath /tmp *.spec"
```

Replace `wget` with the dependencies / package(s) you need to install.

##### How do I change the PyInstaller version used?

Add `pyinstaller=3.1.1` to your `requirements.txt`.

## Known Issues

`cdrx/pyinstaller-windows:python3` has a different Python version to `cdrx/pyinstaller-linux:python3` (3.4) because the Python 3.5 installer doesn't run correctly under Wine. 

## History

#### [1.0] - 2016-08-26
First release, works.

#### [1.1] - 2016-12-13
Added Python 3.4 on Windows, thanks to @bmustiata

## License

MIT
