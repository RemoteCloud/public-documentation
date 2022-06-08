## MkDocs

We use [MkDocs][mkdocs] together with the [material theme][material-theme],  [mike][mike] and [Slate][slate] to build our developer documentation. 

### Local setup 

- Create a [new python virtual environment][python-env]
- Install dependencies from `requirements.txt` via `pip install -r requirements.txt`

### Run MkDocs

Run it via `mkdocs serve`

### Install additional plugins

- Create a virtual environment as described in [local setup](#local-setup).
- Install new plugins
- Update `requirements.txt` via `pip freeze > requirements.txt`

### Navigation structure

We use the [awesome pages plugin][awesome-pages-plugin] for the navigation definition.

## API Versioning

In the GitHub Action we use [widdershins][widdershins] to generate md-files out of all swagger JSON documents found in the swagger-definitions folder. Then we use [Slate][slate] to generate static pages with our API definitions. Afterwards we build MkDocs and the API will be included in the API folder. To update the swagger-definitions you need to execute the `dl-swagger` script in the [scripts folder](./scripts).

## Build Instructions

### Change recomended version

Use `mike set-default --push [version]` to modify the `index.html` file in `gh-pages`. This will define which version will be displayed per default to the user.

### Add new version

Create a new branch with the pattern `v*.*` and GitHub Actions will start a build and deploy the new branch to `gh-pages`.

### Update a version

Just modify any existing branch and GitHub Actions will start a build and deploy the updated branch to `gh-pages`.

### Generating API docs locally

The steps described above are just about running an instance of `mkdocs`. But if you want to generate and see how the actual documentation looks, you need to do some additional steps.

#### Requirements

Ensure that you have following software installed:
- `Python 3`
- `node` and `npm` (tested on `node-v14.15.5` and `npm-6.14.11`)
- `Ruby` (>= `2.5`)

#### Important for macOS users

In case of installation on OSX (macOS), you additionally would need to install `findutils` (`brew install findutils`) to get `xargs` in .sh files work. Also you will need to launch `xxx-osx.sh` scripts (if provided) instead of `xxx.sh` scripts.

#### Installation & generation

##### Environment setup
- Install `widdershins` globally by launching `npm install -g widdershins`
- Remove `slate` directory in your locally cloned project dir
- In root project dir clone [RemoteCloud/slate](https://github.com/RemoteCloud/slate) repository, so `slate` directory will be created again
- Run `bundle install` in `slate` directory to install required packages for `slate`
- Add execution rights to each script in `scripts` directory by performing `chmod +x xxx.sh` on each of them (or just `chmod +x *.sh`)

##### Download swagger definitions

In this step you will fetch all API definitions in JSON file and preserve them in `swagger-definitions` directory.

In `scripts` directory run:

```
sh dl-swagger.sh
```

During execution of the script you will need to provide the **base url** of the `ApiGateway` instance on environment, that contains the latest API definitions.
For Maranics Nightly it would be `https://api.central.nightlybuild.dev`, for your local instance - depending on the `host:port`, specified for ApiGateway application.

##### Run documentation generation

In this step you will convert JSON files to .md files using `widdershins` library. The output will be used for static asset generation for `slate`

In `scripts` directory run:

```
sh local-api-generation.sh
``` 

Note that if you're `macOS` user you should use `local-api-generation-osx` script.

##### Run static asset generation

When documentation files are generated, you should run `slate` bundler to collect and build actual HTML pages that will be shown in `mkdocs`.

In `scripts` directory run:

```
sh local-build-slate.sh
```

During execution, all previously generated .md contents will be transformed to static assets to be served by `mkdocs`.

##### Finish

After steps are done, just run `mkdocs serve` in `mkdocs` dir and you should be able to open and see actual API documentation 

[mkdocs]: https://github.com/mkdocs/mkdocs
[material-theme]: https://squidfunk.github.io/mkdocs-material/
[mike]: https://github.com/jimporter/mike
[python-env]: https://docs.python.org/3/library/venv.html
[awesome-pages-plugin]: https://github.com/lukasgeiter/mkdocs-awesome-pages-plugin
[widdershins]: https://github.com/mermade/widdershins
[slate]: https://github.com/slatedocs/slate
