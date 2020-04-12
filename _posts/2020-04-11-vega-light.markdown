---
layout: none
title:  "Example: Vega-Lite"
date:   2020-04-11 20:09:33 +0000
categories: examples html
sources:
  vega: https://vega.github.io/vega-lite/tutorials/getting_started.html
  observable: https://observablehq.com/
---
<html>
  <head>
    <title>Vega-Lite Bar Chart</title>
    <meta charset="utf-8" />

    <script src="https://cdn.jsdelivr.net/npm/vega@5.10.1"></script>
    <script src="https://cdn.jsdelivr.net/npm/vega-lite@4.10.2"></script>
    <script src="https://cdn.jsdelivr.net/npm/vega-embed@6.5.2"></script>

    <style media="screen">
      /* Add space between Vega-Embed links  */
      .vega-actions a {
        margin-right: 5px;
      }
    </style>
  </head>
  <body>
    <ul>
    <li><a href="/">Home</a></li>
    <li><a href="{{ page.sources.vega }}">Source</a> (linked from <a href="{{ page.sources.observable }}">ObservableHq</a>)</li>
    </ul>

    <h1>Vega-Lite Visualization</h1>
    <!-- Container for the visualization -->
    <div id="vis"></div>

    <script>
      // Assign the specification to a local variable vlSpec.
      var vlSpec = {
        $schema: 'https://vega.github.io/schema/vega-lite/v4.json',
        data: {
          values: [
            {a: 'C', b: 2},
            {a: 'C', b: 7},
            {a: 'C', b: 4},
            {a: 'D', b: 1},
            {a: 'D', b: 2},
            {a: 'D', b: 6},
            {a: 'E', b: 8},
            {a: 'E', b: 4},
            {a: 'E', b: 7}
          ]
        },
        mark: 'bar',
        encoding: {
          y: {field: 'a', type: 'nominal'},
          x: {
            aggregate: 'average',
            field: 'b',
            type: 'quantitative',
            axis: {
              title: 'Average of b'
            }
          }
        }
      };

      // Embed the visualization in the container with id `vis`
      vegaEmbed('#vis', vlSpec);
    </script>
  </body>
</html>
