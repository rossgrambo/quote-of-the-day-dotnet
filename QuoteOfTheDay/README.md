# QuoteOfTheDay

The Quote of the Day app displays a quote upon starting. Users can click the heart button to like the quote. 
The app displays a standard title for some users, while other users will receive a greeting message based on the targeting rules defined in a feature flag.
Feature experimentation (aka. A/B testing) is used to measure whether a personalized greeting message can promote more user engagement by liking the quote.

### Running the Solution

This application requires a database file to run correctly. The file has been removed for security purposes. The file must be generated before running this application. Steps to generate the database file can be found [here](https://learn.microsoft.com/en-us/ef/core/get-started/overview/first-app?tabs=netcore-cli#create-the-database).

### Review Telemetry in Application Insights

Here is an example query you can use to get statistical analysis in Application Insights.

```
// Total users
let total_users =
    customEvents
    | where name == "FeatureEvaluation"
    | where customDimensions.TargetingId startswith "user"
    | extend TargetingId = tostring(customDimensions.TargetingId)
    | extend Variant =  tostring(customDimensions.Variant)
    | distinct TargetingId, Variant
    | summarize TotalUsers = count() by Variant = Variant;
// Hearted users
let hearted_users =
    customEvents
    | where name == "FeatureEvaluation"
    | extend TargetingId = tostring(customDimensions.TargetingId)
    | extend Variant = tostring(customDimensions.Variant)
    | join kind=inner (
        customEvents
        | where name == "Like"
        | extend TargetingId = tostring(customDimensions.TargetingId)
    ) on TargetingId
    | distinct TargetingId, Variant
    | summarize HeartedUsers = count() by Variant = Variant;
// Calculate the percentage of hearted users over total users
let combined_data =
    total_users
    | join kind=leftouter (hearted_users) on Variant
    | extend HeartedUsers = coalesce(HeartedUsers, 0)
    | extend PercentageHearted = strcat(round(HeartedUsers * 100.0 / TotalUsers, 1), "%")
    | project Variant, TotalUsers, HeartedUsers, PercentageHearted;
// Calculate the sum of total users and hearted users of all variants
let total_sum =
    combined_data
    | summarize Variant="All", TotalUsers = sum(TotalUsers), HeartedUsers = sum(HeartedUsers);
// Display the combined data along with the sum of total users and hearted users
combined_data
| union (total_sum)
```

