#!/usr/bin/env bash
{
  ver=2.x

  ${JULIA-julia} gen_imgs.jl $ver

  for f in imgs/$ver/*.txt; do
    html=${f%.txt}.html
    cat $f | ${ANSI2HTML-ansi2html} --input-encoding=utf-8 --output-encoding=utf-8 >$html
    ${WKHTMLTOIMAGE-wkhtmltoimage} --quiet --crop-w 800 --quality 85 $html ${html%.html}.png
  done

  rm imgs/$ver/*.txt 
  rm imgs/$ver/*.html
}
