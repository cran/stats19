stats19: a package for road safety research
================
Layik Hama and Robin Lovelace
2019-02-15

Introduction
------------

**stats19** is a new R package that enables access to and processing of Great Britain's official road traffic casualty database, [STATS19](https://data.gov.uk/dataset/cb7ae6f0-4be6-4935-9277-47e5ce24a11f/road-safety-data). It has been peer reviewed thanks to rOpenSci and is now published in the Journal of Open Source Software ([JOSS](https://joss.theoj.org/papers/10.21105/joss.01181)) (Lovelace et al. 2019). For installation and the code, see its home in rOpenSci: <https://github.com/ropensci/stats19>, and the package documentation at <https://itsleeds.github.io/stats19/>.

In this post for [rOpenSci](https://ropensci.github.io/), we'll provide a bit of context, show how the package works, and provide ideads for future work building on the experience. Now is a good time to report on the package: version [`0.2.0`](https://cran.r-project.org/web/packages/stats19/index.html) has just been release on CRAN, which contains a few improvements, some of which are used in this blog post (`ask = FALSE` in `get_stats19()`, for example, which makes it even quicker to get data with this package).

We started the package in late 2018 following three main motivations:

1.  The release of the 2017 road crash statistics, which showed worsening road safety in some areas, increasing the importance of making the data more accessible.
2.  The realisation that many researchers were writing add-hoc code to clean the data, with a huge amount of duplicated (wasted) effort and potential for mistakes to lead to mistakes in the labelling of the data (more on that below).
3.  An understanding of the concept of 'modularity' in software design, following the [Unix philosophy](https://en.wikipedia.org/wiki/Unix_philosophy) that programs should 'do one thing and do it well'. This realisation has led to code inside the rOpenSci-hosted package [`stplanr`](https://github.com/ropensci/stplanr) being split-out into 2 separate packages already: [`cyclestreets`](https://github.com/Robinlovelace/cyclestreets) and [`stats19`](https://github.com/ropensci/stats19).

The main authors are based at the [Institute for Transport Studies (ITS)](https://environment.leeds.ac.uk/transport) and the [Leeds Institute for Data Analytics (LIDA)](https://lida.leeds.ac.uk/), institutions focussed on transport and data-intensive research. We have prior experience writing code to work with road crash data: Robin wrote code for an academic paper on cycle safety in Yorkshire based on STATS19 data (Lovelace, Roberts, and Kellar 2016), and put it in the [robinlovelace/bikeR](https://github.com/Robinlovelace/bikeR) repo for posterity/reproducibility. Package contributor, Dr Malcolm Morgan, wrote code processing different STATS19 data for the Cycling Infrastructure Prioritisation Toolkit ([CyIPT](https://www.cyipt.bike)) and put it in [cyipt/stats19](https://github.com/cyipt/stats19). The large and complex STATS19 data from the UK's Department for Transport, which is open access but difficult-to-use, represented a perfect opportunity for us to get stuck into a chunky data processing challenge.

We have a wider motivation: we want the roads to be safer. By making data on the nature of road crashes in the UK more publicly accessible (in a usable format), we hope this package saves lives.

What is STATS19 anyway?
-----------------------

One of the reviewer comments from the [rOpenSci review process (which has 77 comments - lots of knowledge shared)](https://github.com/ropensci/software-review/issues/266) alluded to the package's esoteric name:

> I confess I wish the package name was more expressive--stats19 sounds like an introductory statistics class.

We agree! However, the priority with the package is to remain faithful to the data, and alternative name options, such as stats19data, roadcrashesUK and roadSafetyData were not popular. Furthermore, the term 'stats19' is strongly associated with road crash data online. The URL <https://en.wikipedia.org/wiki/STATS19> resolves to <https://en.wikipedia.org/wiki/Reported_Road_Casualties_Great_Britain>, for example (this page is provides and excellent introduction to STATS19).

The name comes from a UK police form called [STATS19](https://assets.publishing.service.gov.uk/government/uploads/system/uploads/attachment_data/file/775149/Operational_Metrics_Manual.pdf) (note the capital letters). Why STATS19 and not, say, STATS18 or STATS20? We're not sure, but there *is* an official [STATS20 product](https://assets.publishing.service.gov.uk/government/uploads/system/uploads/attachment_data/file/230596/stats20-2011.pdf), which explains what STATS19 data is and provides guidelines to officers filling in STATS19 form (it's a 100+ page document providing lots of detail on each variable collected, so worth checking out if you want detail). An important point is that the dataset omits crashes in which nobody was hurt, as emphasised by another government [document](https://assets.publishing.service.gov.uk/government/uploads/system/uploads/attachment_data/file/743853/reported-road-casualties-gb-notes-definitions.pdf):

> The STATS19 data are therefore not a complete record of all injury accidents and this should be borne in mind when using and analysing the data. However, they remain the most detailed, complete and reliable single source of information on road casualties covering the whole of Great Britain, in particular for monitoring trends over time

The Department for Transport (DfT) also names the dataset [STATS19 on the main web page that links to open access road crash data](https://data.gov.uk/dataset/cb7ae6f0-4be6-4935-9277-47e5ce24a11f/road-safety-data).

The importance of road safety and informed decision making based on crash data cannot be overstated. Two numbers from a strategy [document](https://assets.publishing.service.gov.uk/government/uploads/system/uploads/attachment_data/file/8146/strategicframework.pdf) by the UK government (2011) are worth mentioning here:

> The economic welfare costs \[of road collisions\] are estimated at around £16 billion a year while insurance payouts for motoring claims alone are now over £12 billion a year.

Even more shocking are the [global statistics](https://www.who.int/gho/road_safety/mortality/en/), as summarised by an open access and reproducible academic [paper that uses data from the package to explore car-pedestrian crashes](https://github.com/Robinlovelace/stats19-gisruk):

> While so many people die on the roads each year in the UK (1,793 people in 2017, 3 deaths per 100,000) and worldwide (1,250,000 people in 2015, 17 deaths per 100,000) and ‘vision zero’ remains a Swedish dream (Johansson 2009), we urge people researching STATS19 and other road safety datasets to focus on a more urgent question: how to stop this carnage?

The road crash data in stats19
------------------------------

There are three main different types of CSV files released by the DfT: `accidents`, `vehicles` and `casualties` tables. There is a schema covering these tables but a good amount of work is needed to understand it, let alone be able to the data contained within the files and convert the integers they contain into meaningful data.

The annual statistics have not been released in a consistent way either, making it hard for people to download, or even find, the relevant files. For example, there are separate files for each of the above tables for certain years (e.g. 2016, 2017) but not for all of 1979 - 2017 or 2018 now. The largest chunk is the 1979 - 2004 data, which is made available in a huge ZIP file ([link](http://data.dft.gov.uk/road-accidents-safety-data/Stats19-Data1979-2004.zip)). Unzipped this contains the following 3 files, which occupy almost 2 GB on your hard drive:

``` sh
721M Apr  3  2013 Accidents7904.csv
344M Apr  3  2013 Casualty7904.csv
688M Apr  3  2013 Vehicles7904.csv
# total 1.753 GB data
```

How stats19 works
-----------------

With those introductions out of the way, lets see what the package can do and how it can empower people (including target audiences of academics, policy makers and road safety campaigners and R programmers/analysts wanting to test their skills on a large spatio-temporal dataset) to access STATS19 data, back to 1979. First install the package in the usual way:

``` r
# release version - currently 0.2.0
install.packages("stats19") 
# dev version
# remotes::install_github("ropensci/stats19") 
```

Attach the package as follows:

``` r
library(stats19)
```

The easiest way to get STATS19 data is with `get_stats19()`. This function takes 2 main arguments, `year` and `type`. The year can be any year between 1979 and 2017.

``` r
crashes_2017 = get_stats19(year = 2017, type = "Accidents", ask = FALSE)
nrow(crashes_2017)
```

    ## [1] 129982

What just happened? We just downloaded, cleaned and read-in data on all road crashes recorded by the police in 2017 across Great Britain. We can explore the `crashes_2017` object a little more:

``` r
column_names = names(crashes_2017)
length(column_names)
```

    ## [1] 32

``` r
head(column_names)
```

    ## [1] "accident_index"         "location_easting_osgr" 
    ## [3] "location_northing_osgr" "longitude"             
    ## [5] "latitude"               "police_force"

``` r
class(crashes_2017)
```

    ## [1] "spec_tbl_df" "tbl_df"      "tbl"         "data.frame"

``` r
kableExtra::kable(head(crashes_2017[, c(1, 4, 5, 7, 10)]))
```

<table>
<thead>
<tr>
<th style="text-align:left;">
accident\_index
</th>
<th style="text-align:right;">
longitude
</th>
<th style="text-align:right;">
latitude
</th>
<th style="text-align:left;">
accident\_severity
</th>
<th style="text-align:left;">
date
</th>
</tr>
</thead>
<tbody>
<tr>
<td style="text-align:left;">
2017010001708
</td>
<td style="text-align:right;">
-0.080107
</td>
<td style="text-align:right;">
51.65006
</td>
<td style="text-align:left;">
Fatal
</td>
<td style="text-align:left;">
2017-08-05
</td>
</tr>
<tr>
<td style="text-align:left;">
2017010009342
</td>
<td style="text-align:right;">
-0.173845
</td>
<td style="text-align:right;">
51.52242
</td>
<td style="text-align:left;">
Slight
</td>
<td style="text-align:left;">
2017-01-01
</td>
</tr>
<tr>
<td style="text-align:left;">
2017010009344
</td>
<td style="text-align:right;">
-0.052969
</td>
<td style="text-align:right;">
51.51410
</td>
<td style="text-align:left;">
Slight
</td>
<td style="text-align:left;">
2017-01-01
</td>
</tr>
<tr>
<td style="text-align:left;">
2017010009348
</td>
<td style="text-align:right;">
-0.060658
</td>
<td style="text-align:right;">
51.62483
</td>
<td style="text-align:left;">
Slight
</td>
<td style="text-align:left;">
2017-01-01
</td>
</tr>
<tr>
<td style="text-align:left;">
2017010009350
</td>
<td style="text-align:right;">
-0.072372
</td>
<td style="text-align:right;">
51.57341
</td>
<td style="text-align:left;">
Serious
</td>
<td style="text-align:left;">
2017-01-01
</td>
</tr>
<tr>
<td style="text-align:left;">
2017010009351
</td>
<td style="text-align:right;">
-0.353876
</td>
<td style="text-align:right;">
51.43876
</td>
<td style="text-align:left;">
Slight
</td>
<td style="text-align:left;">
2017-01-01
</td>
</tr>
</tbody>
</table>
The package contains the names of all "zip" files released by the DfT and hosted on Amazon servers to download. These file names have been included in the package and can be found under `file_names` variable name. for example:

``` r
stats19::file_names$dftRoadSafetyData_Vehicles_2017.zip
```

    ## [1] "dftRoadSafetyData_Vehicles_2017.zip"

You can also get the raw data (if you really want!) to see how much more useful the data is after it has been cleaned and labelled by the `stats19` package, compared with the data provided by government:

``` r
crashes_2017_raw = get_stats19(year = 2017, type = "Accidents", ask = FALSE, format = FALSE)
```

    ## Files identified: dftRoadSafetyData_Accidents_2017.zip

    ##    http://data.dft.gov.uk.s3.amazonaws.com/road-accidents-safety-data/dftRoadSafetyData_Accidents_2017.zip

    ## Data already exists in data_dir, not downloading

    ## Data saved at /tmp/Rtmprctsek/dftRoadSafetyData_Accidents_2017/Acc.csv

    ## Reading in:

    ## /tmp/Rtmprctsek/dftRoadSafetyData_Accidents_2017/Acc.csv

``` r
kableExtra::kable(head(crashes_2017_raw[, c(1, 4, 5, 7, 10)]))
```

<table>
<thead>
<tr>
<th style="text-align:left;">
Accident\_Index
</th>
<th style="text-align:right;">
Longitude
</th>
<th style="text-align:right;">
Latitude
</th>
<th style="text-align:right;">
Accident\_Severity
</th>
<th style="text-align:left;">
Date
</th>
</tr>
</thead>
<tbody>
<tr>
<td style="text-align:left;">
2017010001708
</td>
<td style="text-align:right;">
-0.080107
</td>
<td style="text-align:right;">
51.65006
</td>
<td style="text-align:right;">
1
</td>
<td style="text-align:left;">
05/08/2017
</td>
</tr>
<tr>
<td style="text-align:left;">
2017010009342
</td>
<td style="text-align:right;">
-0.173845
</td>
<td style="text-align:right;">
51.52242
</td>
<td style="text-align:right;">
3
</td>
<td style="text-align:left;">
01/01/2017
</td>
</tr>
<tr>
<td style="text-align:left;">
2017010009344
</td>
<td style="text-align:right;">
-0.052969
</td>
<td style="text-align:right;">
51.51410
</td>
<td style="text-align:right;">
3
</td>
<td style="text-align:left;">
01/01/2017
</td>
</tr>
<tr>
<td style="text-align:left;">
2017010009348
</td>
<td style="text-align:right;">
-0.060658
</td>
<td style="text-align:right;">
51.62483
</td>
<td style="text-align:right;">
3
</td>
<td style="text-align:left;">
01/01/2017
</td>
</tr>
<tr>
<td style="text-align:left;">
2017010009350
</td>
<td style="text-align:right;">
-0.072372
</td>
<td style="text-align:right;">
51.57341
</td>
<td style="text-align:right;">
2
</td>
<td style="text-align:left;">
01/01/2017
</td>
</tr>
<tr>
<td style="text-align:left;">
2017010009351
</td>
<td style="text-align:right;">
-0.353876
</td>
<td style="text-align:right;">
51.43876
</td>
<td style="text-align:right;">
3
</td>
<td style="text-align:left;">
01/01/2017
</td>
</tr>
</tbody>
</table>
Note: the severity type is not labelled (this problem affects dozens of columns), the column names are inconsistent, and the dates have note been cleaned and converted into a user-friendly date (`POSIXct`) class:

``` r
class(crashes_2017$date)
```

    ## [1] "POSIXct" "POSIXt"

``` r
class(crashes_2017_raw$Date)
```

    ## [1] "character"

Creating geographic crash data
------------------------------

An important feature of STATS19 data is that the "accidents" table contains geographic coordinates. These are provided at ~10m resolution in the UK's official coordinate reference system (the Ordnance Survey National Grid, EPSG code 27700). **stats19** converts the non-geographic tables created by `format_accidents()` into the geographic data form of the [`sf` package](https://cran.r-project.org/package=sf) with the function `format_sf()` as follows:

``` r
crashes_sf = format_sf(crashes_2017)
```

    ## 19 rows removed with no coordinates

``` r
# crashes_sf = format_sf(crashes_2017, lonlat = TRUE) # provides the data in lon/lat format
```

An example of an administrative zone dataset of relevance to STATS19 data is the boundaries of police forces in England, which is provided in the packaged dataset `police_boundaries`. The following code chunk demonstrates the kind of spatial operations that can be performed on geographic STATS19 data, by counting and plotting the number of fatalities per police force:

``` r
library(sf)
library(dplyr)
crashes_sf %>% 
  filter(accident_severity == "Fatal") %>% 
  select(n_fatalities = accident_index) %>% 
  aggregate(by = police_boundaries, FUN = length) %>% 
  plot()
```

![](blog_files/figure-markdown_github/nfatalities-1.png)

``` r
west_yorkshire =
  police_boundaries[police_boundaries$pfa16nm == "West Yorkshire", ]
```

``` r
crashes_wy = crashes_sf[west_yorkshire, ]
nrow(crashes_wy) # which is 3.36%
```

    ## [1] 4371

Combining the tables
--------------------

We can combine the three sets of tables to analyse the data further. Lets read the datasets first:

``` r
#crashes_2017 = get_stats19(year = 2017, type = "Accidents", ask = FALSE)
casualties_2017 = get_stats19(year = 2017, type = "Casualties", ask = FALSE)
nrow(casualties_2017)
```

    ## [1] 170993

``` r
vehicles_2017 = get_stats19(year = 2017, type = "Vehicles", ask = FALSE)
nrow(vehicles_2017)
```

    ## [1] 238926

Lets now read in casualties that took place in West Yorkshire (using `crashes_wy` object above), and count the number of casualties by severity for each crash:

``` r
library(tidyr)
library(dplyr)
sel = casualties_2017$accident_index %in% crashes_wy$accident_index
casualties_wy = casualties_2017[sel, ]
cas_types = casualties_wy %>% 
  select(accident_index, casualty_type) %>% 
  group_by(accident_index) %>% 
  summarise(
    Total = n(),
    walking = sum(casualty_type == "Pedestrian"),
    cycling = sum(casualty_type == "Cyclist"),
    passenger = sum(casualty_type == "Car occupant")
    ) 
cj = left_join(crashes_wy, cas_types)
```

What just happened?

We found the subset of casualties that took place in West Yorkshire with reference to the `accident_index` variable in the `accidents` table. Then we used the **dplyr** function `summarise()`, to find the number of people who were in a car, cycling, and walking when they were injured. This new casualty dataset is joined onto the `crashes_wy` dataset. The result is a spatial (`sf`) data frame of crashes in West Yorkshire, with columns counting how many road users of different types were hurt. The joined data has additional variables:

``` r
base::setdiff(names(cj), names(crashes_wy))
```

    ## [1] "Total"     "walking"   "cycling"   "passenger"

In addition to the `Total` number of people hurt/killed, `cj` contains a column for each type of casualty (cyclist, car occupant, etc.), and a number corresponding to the number of each type hurt in each crash. It also contains the `geometry` column from `crashes_sf`. In other words, joins allow the casualties and vehicles tables to be geo-referenced. We can then explore the spatial distribution of different casualty types. The following figure, for example, shows the spatial distribution of pedestrians and car passengers hurt in car crashes across West Yorkshire in 2017:

``` r
library(ggplot2)
crashes_types = cj %>% 
  filter(accident_severity != "Slight") %>% 
  mutate(type = case_when(
    walking > 0 ~ "Walking",
    cycling > 0 ~ "Cycling",
    passenger > 0 ~ "Passenger",
    TRUE ~ "Other"
  ))
ggplot(crashes_types, aes(size = Total, colour = speed_limit)) +
  geom_sf(show.legend = "point", alpha = 0.3) +
  facet_grid(vars(type), vars(accident_severity)) +
  scale_size(
    breaks = c(1:3, 12),
    labels = c(1:2, "3+", 12)
    ) +
  scale_color_gradientn(colours = c("blue", "yellow", "red")) +
  theme(axis.text = element_blank(), axis.ticks = element_blank())
```

<img src="blog_files/figure-markdown_github/sfplot-1.png" alt="Spatial distribution of serious and fatal collisions in which people who were walking on the road network ('pedestrians') were hit by a car or other vehicle." width="100%" />
<p class="caption">
Spatial distribution of serious and fatal collisions in which people who were walking on the road network ('pedestrians') were hit by a car or other vehicle.
</p>

To show what is possible when the data are in this form, and allude to next steps, let's create an interactive map. We will plot crashes in which pedestrians were hurt, from the `crashes_types`, using Rstudio's `leaflet` package:

``` r
library(leaflet)
crashes_pedestrians = crashes_types %>% 
  filter(walking > 0)
# convert to lon lat CRS
crashes_pedestrians_lonlat = st_transform(crashes_pedestrians, crs = 4326)
pal = colorFactor(palette = "Reds", domain = crashes_pedestrians_lonlat$accident_severity, reverse = TRUE)
leaflet(data = crashes_pedestrians_lonlat, height = "280px") %>%
  addProviderTiles(provider = providers$OpenStreetMap.BlackAndWhite) %>%
  addCircleMarkers(radius = 0.5, color = ~pal(accident_severity)) %>% 
  addLegend(pal = pal, values = ~accident_severity) %>% 
  leaflet::addMiniMap(toggleDisplay = TRUE)
```

    ## TypeError: Attempting to change the setter of an unconfigurable property.
    ## TypeError: Attempting to change the setter of an unconfigurable property.

<div class="figure">
<img src="blog_files/figure-markdown_github/crashes-map-1.png" alt="Spatial distribution of all collisions in which people who were walking on the road network ('pedestrians') were hit by a car or other vehicle in 2017 within West Yorkshire boundary." width="100%" />

Conclusion
----------

[`stats19`](https://github.com/ropensci/stats19) provides access to a reliable and official road safety dataset. As covered in this post, it helps with data discovery, download, cleaning and formatting, allowing you to focus on the real work of analysis (see the package's introductory [vignette](https://itsleeds.github.io/stats19/articles/stats19.html) for more on this). In our experience, 80% of time spent using STATS19 data was spent on data cleaning. Hopefully, now the data is freely available in a more useful form, 100% of the time can be spent on analysis! We think it could help many people, especially, including campaigners, academics and local authority planners aiming to make the roads of the UK and the rest of the world a safe place for all of us.

There are many possible next steps, including:

-   Comparing these datasets with interventions such as 20 mph zones (Grundy et al. 2009) and links with street morphology (Sarkar, Webster, and Kumari 2018).
-   The creation of more general software for accessing and working with road crash data worldwide.
-   Making the data even more available by provide the data as part of an interactive web application, a technique successfully used in the Propensity to Cycle Tool (PCT) project hosted at [www.pct.bike/](https://www.pct.bike/) (this would likely take further times/resources beyond what we can provide in our spare time!).

For now, however, we want to take the opportunity to celebrate the release of `stats19` 🎉, thank rOpenSci for a great review process 🙏 and let you know: the package and data are now out there, and are ready to be used 🚀.

References
----------

Grundy, Chris, Rebecca Steinbach, Phil Edwards, Judith Green, Ben Armstrong, and Paul Wilkinson. 2009. “Effect of 20 Mph Traffic Speed Zones on Road Injuries in London, 1986-2006: Controlled Interrupted Time Series Analysis.” *BMJ* 339 (December): b4469. doi:[10.1136/bmj.b4469](https://doi.org/10.1136/bmj.b4469).

Lovelace, Robin, Malcolm Morgan, Layik Hama, Mark Padgham, and M Padgham. 2019. “Stats19 A Package for Working with Open Road Crash Data.” *Journal of Open Source Software* 4 (33): 1181. doi:[10.21105/joss.01181](https://doi.org/10.21105/joss.01181).

Lovelace, Robin, Hannah Roberts, and Ian Kellar. 2016. “Who, Where, When: The Demographic and Geographic Distribution of Bicycle Crashes in West Yorkshire.” *Transportation Research Part F: Traffic Psychology and Behaviour*, Bicycling and bicycle safety, 41, Part B. doi:[10.1016/j.trf.2015.02.010](https://doi.org/10.1016/j.trf.2015.02.010).

Sarkar, Chinmoy, Chris Webster, and Sarika Kumari. 2018. “Street Morphology and Severity of Road Casualties: A 5-Year Study of Greater London.” *International Journal of Sustainable Transportation* 12 (7): 510–25. doi:[10.1080/15568318.2017.1402972](https://doi.org/10.1080/15568318.2017.1402972).
