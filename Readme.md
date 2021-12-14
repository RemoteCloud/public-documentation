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


[mkdocs]: https://github.com/mkdocs/mkdocs
[material-theme]: https://squidfunk.github.io/mkdocs-material/
[mike]: https://github.com/jimporter/mike
[python-env]: https://docs.python.org/3/library/venv.html
[awesome-pages-plugin]: https://github.com/lukasgeiter/mkdocs-awesome-pages-plugin
[widdershins]: https://github.com/mermade/widdershins
[slate]: https://github.com/slatedocs/slate
