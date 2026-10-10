# Nikhil Yadav · Portfolio

**Live:** [nikhil.runs-on.dev](https://nikhil.runs-on.dev)

My portfolio, built in Flutter for the web. A phone sits in a sky that changes with the mood you pick: sky, hills, rain, glass panels and the app inside all follow it. Strobi, the mascot on the mood panel, acts the mood out too.

## Run it

```sh
flutter pub get
flutter run -d chrome
```

The résumé (`/resume.pdf`) is only served by a release build:

```sh
flutter build web --release --base-href "/"
```

Pushing to `master` deploys to GitHub Pages via `.github/workflows/deploy.yml`. Each deploy refreshes the contribution graph from my GitHub profile (`tool/fetch_contributions.py`).

## Mascot

Strobi was designed in [Bible Strong Avatar Lab](https://github.com/smontlouis/bible-strong-avatar-lab). The site's version is generated from the Studio export:

```sh
python tool/mascot/build_strobi.py
```

## Credits

- **Original template:** this project started from [high-coder/awesome_portfolio](https://github.com/high-coder/awesome_portfolio). That repository states no licence, so any code that remains from it belongs to its author and isn't covered by the licence below.
- **Mascot renderer:** [`@bible-strong/avatar-web`](https://github.com/smontlouis/bible-strong-avatar-lab) by Stéphane Montlouis-Calixte, AGPL-3.0. It's loaded at runtime from jsDelivr and isn't stored in this repo.

## Licence

My code in this repository is licensed under the [GNU Affero General Public License v3.0](LICENSE).
