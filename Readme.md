## MkDocs

We use [MkDocs][mkdocs] together with the [material theme][material-theme] and [mike][mike] to build our developer documentation. 

### Local setup 

- Create a [new python virtual environment][python-env]
- Install dependencies from `requirements.txt` via `pip install -r requirements.txt`

### Run MkDocs

Run it via `mkdocs serve`

### Install additional plugins

- Create a virtual environment as described in [local setup][#local-setup].
- Install new plugins
- Update `requirements.txt` via `pip freeze > requirements.txt`

### Navigation structure

We use the [awesome pages plugin][awesome-pages-plugin] for the navigation definition.


## API Version

We use [widdershins][widdershins] to generate a md file out of our swagger document. Then we use [slate][slate] to generate a static page with our API definition. Afterwards we build MkDocs and the API will be included in the API folder. At the moment we need to manually update which API version it needs to build as well as updating the version when a minor version changes.

```
# retrieve swagger definition from API gateway
wget --directory-prefix ./ –output-document swagger.json https://.../v1/swagger.json

# convert
widdershins swagger.json -o ./slate/source/index.html.md

# build static page
bundle exec middleman build --clean --data-dir ./slate/source --build-dir ./docs/api
```


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