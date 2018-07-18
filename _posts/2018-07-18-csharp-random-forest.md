---
layout: post
title: "Productionizing an R random forest in C#"
date: "2018-07-18 11:00:00 -0300"
---
You've got a nice random forest built in R... how can you make it work in your c# app? `dotnet add package RandomForest`.

<!--more-->
At some point, I thought I'd write an article for each side project I work on. But... coding is easier than writing. This article is about a project I worked on last year and forgot about... until somebody [made an issue on GH](https://github.com/g3rv4/RandomForest/issues/1) because they're actually using it! So... here comes the article, a year later.

## TL;DR
I built [a tiny library](https://github.com/g3rv4/RandomForest) to run random forests built in R on C#.

## This only happened because I'm lucky to work at a place where I learn constantly
At Stack Overflow, we have a biweekly session with our Data Scientist (hi [Julia](https://juliasilge.com/)!) where we work together trying to answer a question by using our data and R. This was started by [Dave](http://varianceexplained.org/) and as I can't recall who led the session where I played with random forests, I'll just say hi to both of them :)

## But... what the heck is a random forest?
Of course, [wikipedia has the answer](https://en.wikipedia.org/wiki/Random_forest). It's "just" a collection of [decision trees](https://en.wikipedia.org/wiki/Decision_tree) carefully chosen to predict something. If you want to predict the math grade of a student based on their age, their previous grade and their height, each tree would use those variables to come up with a result. Then, the prediction of the forest would be the average for the results chosen by those trees.

And, if you're good at choosing the underlying trees, this approach works very well for some problems.

## What is the problem then?
After we had our random forest working (we used some nice packages in R to build them)... they mentioned that at that time, we didn't really have a way of productionizing it. Our data team was looking into [running R in SQL Server](https://docs.microsoft.com/en-us/sql/advanced-analytics/r/sql-server-r-services?view=sql-server-2017), but I figured that if a random forest is just a collection of decision trees... then it shouldn't be complicated to run them in c#.

Then... I started trying to make it happen. Not because we had a use case for it (although secretly I was hoping we would to prove this was better than relying on SQL Server running R) but mainly to see if I could do it. I could :)

## Kewl, so how can I use it?
In order to make predictions based on a random forest built in R you need to:

* Actually have a random forest model (duh)
* Export it as [PMML](https://en.wikipedia.org/wiki/Predictive_Model_Markup_Language)
* Loading the random forest on C#
* Build the row with the data
* Call a function
* Pr0fit!

### Having a random forest
Well, this is well beyond the scope of the library. I'll assume you know what you're doing (because I don't). I put together [a couple models](https://github.com/g3rv4/RandomForests) so that I could test that the library returns the same results as R's `predict` both for [classification](https://github.com/g3rv4/RandomForests/blob/master/ClassificationRandomForest.Rmd) and [regression](https://github.com/g3rv4/RandomForests/blob/master/RegressionRandomForest.Rmd) random forests.

### Exporting the model as a PMML
This is the painful part. I'm using the [r2pmml](https://github.com/jpmml/r2pmml) package but... it needs... JAVA ¯\\\_(ツ)\_/¯. Once you have it installed actually using it is extremely straightforward:

```
library(r2pmml)
r2pmml(model, "my_model.pmml")
```

### Loading the random forest on C\#
Just instantiate an `XmlReader` pointing to the file and pass the reader to the forest instance. The loader streams through the file, so if the model is huge it still won't use lots of memory to parse the xml.

```
RegressionRandomForest randomForest; // If you have a classification random forest, then use the ClassificationRandomForest class instead
using (XmlReader reader = XmlReader.Create("my_model.pmml"))
{
    randomForest = new RegressionRandomForest(reader);
}
```

### Building the row with the data
Alright! now you have the model. If you want to predict something, you should provide the data you have so that the model can do its thing :)

You can either use a `Dictionary<string, string>` or a `Dictionary<string, double>`. The latter is more efficient (because the former just gets converted).

The format you need to use are:

```
var row = new Dictionary<string, string> {
    ["Name"] = "Gervasio Marchand",
    ["Age"] = "34"
}
```

or

```
var row = new Dictionary<string, double> {
    ["NameGervasio Marchand"] = 1,
    ["Age"] = 34
}
```

### Calling the predict function
Aaand, just doing `double predictedValue = randomForest.Predict(row);` will get you the same prediction as R.

## What if I wanted to see the probability of each option?
If you're using a `ClassificationRandomForest`, you can get the probability of each outcome (this is actually what the first user asked for).

I didn't really know what it was, so I looked it up and it's just the percentage of decision trees that chose a value.

If you're predicting "is this room occupied?" based on humidity, temperature, CO2, etc. the possible answers are "yes" and "no". If we have a model that has 100 trees, and for a value of humidity, temperature and CO2 45 trees say "yes" and 55 trees say "no", then the probability of "yes" is 0.45.

You can get that by doing `var cSharpProbabilities = classificationRF.GetProbabilities(row);`

# What's next
I don't have big plans for it... but after coming back to this code:

* There's one thing that makes my eye twitch... and it's the fact that I have a sample project that I use to test the outputs. They should be unit tests.
* I'd like to benchmark how much running the trees in parallel improve its speed.

And then... move to the next project? well, I should say... next article.
