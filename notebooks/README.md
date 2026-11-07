# Notebooks

Exploration notebooks. Outputs are **stripped before commit**, so no images from `data/` end up in git.
Run them with the digitiser environment (`data/third_party/venv-digitiser`, see `ml/digitise/README.md`),
which also has Jupyter: `python -m jupyter lab notebooks/`. A GPU makes them faster; they also run on CPU.

| Notebook | What it shows |
|---|---|
| `03_digitiser_walkthrough.ipynb` | The ECG-Digitiser CNN (U-Net): architecture, filters, feature maps, per-pixel probabilities, uncertainty on a page vs a photo, occlusion test. Uses only a public PTB-XL page and a simulated photo. |

Rendered copies (with outputs) can be made with
`python -m jupyter nbconvert --to html --execute <notebook> --output-dir data/notebooks_html` (git-ignored).
