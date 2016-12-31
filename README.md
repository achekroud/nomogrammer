# nomogrammer: Fagan's nomograms with ggplot2

The [Fagan nomogram](http://www.pmean.com/definitions/fagan.htm) is a graphical tool for estimating how much the result on a diagnostic test changes the probability that a patient has a disease (NEJM 1975; 293: 257)

<p align="center">
  <img src="https://github.com/achekroud/nomogrammer/blob/master/demo.png" width="550">
</p>

This repository contains the latest version of the `nomogrammer` function, which allows you to plot Fagan's nomgrams with [`ggplot2`](http://ggplot2.org/).

## INSTALL

`nomogrammer` is a standalone function from this repository:

```{r}
source("https://raw.githubusercontent.com/achekroud/nomogrammer/master/nomogrammer.r")
```

## VIGNETTE

The `nomogrammer` function is fully documented in [this vignette](https://briatte.github.io/ggcorr).

The [vignette source](vignette) is included in this repository.

### THANKS

- Alan Schwartz [(UIC)](http://ulan.mede.uic.edu/alansz/) helped me translate this into R based on his [Perl web-implementation](https://araw.mede.uic.edu/cgi-bin/testcalc.pl)

You may also enjoy:
- a static web-implementation in [Perl](https://sourceforge.net/projects/testcalc/)
- a dynamic visualization in [d3](https://cscheid.net/projects/fagan_nomogram/).

For more involved/complex nomograms, you could use:
- the [hdnom R-package](https://cran.r-project.org/web/packages/hdnom/vignettes/hdnom.html) in R
- the [pynomo](http://pynomo.org/wiki/index.php?title=Main_Page) package in Python.
