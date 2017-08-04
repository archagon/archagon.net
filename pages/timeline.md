---
layout: page
title: Travel
permalink: /timeline/
---
<style>article.timeline { width: 600px; }</style>

<p><article class="timeline">
    {%include timeline-us-trip-2013.html %}
</article></p>

<p>
{% assign timeline-template-trips = site.data.trips | where: "id", "europe-2014" %}
{% include timeline-template.html %}
</p>

This is just a test of my Jekyll timeline include. More coming later!