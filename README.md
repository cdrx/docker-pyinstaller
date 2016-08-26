# PyInstaller Docker Images

**cdrx/pyinstaller-linux** and **cdrx/pyinstaller-windows** are a pair of Docker containers to ease compiling Python applications to binaries / exe files.

Current PyInstaller version used: 3.2.

## Tags

`cdrx/pyinstaller-linux` has two tags, `:python2` and `:python3` which you can use depending on the requirements of your project. `:latest` points to `:python3`

`cdrx/pyinstaller-windows` currently only has a `:python2` tag because the Python 3.5 Windows installer doesn't work under Wine (yet).

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

There is currently no `cdrx/pyinstaller-windows:python3` image because the Python 3.5 installer doesn't work under Wine. The `cdrx/pyinstaller-windows:python2` tag works.

## History

#### [1.0] - 2016-08-26
First release, works.

## License

MIT
