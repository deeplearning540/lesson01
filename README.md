# Slidedeck template

This repo helps to build presentations in the helmholtz AI layout from markdown input (for help on the syntax see [this page](https://github.com/jgm/pandoc/wiki/Using-pandoc-to-produce-reveal.js-slides)) to reveal.js inspired html5 slides.

## slides

To view the slides, consult [deeplearning540.github.io/lesson01](https://deeplearning540.github.io/lesson01).

## How to build

First, do the following will try to install all required dependenices:

```
$ make prepare 
```

Second, edit [index.md](./index.md) to your liking.

Third, build the page `index.html` by invoking:

```
$ make 
```

To start from scratch, use (but keep `reveal.js` around):

```
$ make clean 
```

To remove all slide outputs and more, use:


```
$ make distclean
```
