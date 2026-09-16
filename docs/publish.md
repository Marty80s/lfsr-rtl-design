# Repository maintenance

Canonical repository: https://github.com/Marty80s/lfsr-rtl-design

Clone the repository, make changes, run the applicable checks, and commit source files and documentation. Generated simulation and synthesis outputs are excluded by `.gitignore`.

```bash
git clone https://github.com/Marty80s/lfsr-rtl-design.git
cd lfsr-rtl-design
make check
git add README.md rtl tb scripts constraints docs Makefile .gitignore
git commit -m "Describe your change"
git push origin main
```

`make check` requires Icarus Verilog. It runs demonstrations and compilation checks, not a self-checking functional regression. Run Genus separately in a configured, licensed environment before claiming synthesis results.
