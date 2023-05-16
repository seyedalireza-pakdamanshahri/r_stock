# Install required packages
if (!require(quantmod)) install.packages('quantmod')
if (!require(randomForest)) install.packages('randomForest')

# Load required packages
library(quantmod)
library(randomForest)

# Define the ticker symbol
ticker_symbol <- 'AAPL'

# Download stock prices
getSymbols(ticker_symbol, src = "yahoo", from = '2020-01-01', to = Sys.Date())

# Create data frame
data <- data.frame(Date=index(AAPL), coredata(AAPL))

# Create lagged features for past 5 days
for (i in 1:5) {
  data[paste('Lag', i, sep = '.' )] <- lag(data$AAPL.Adjusted, i)
}

# Remove rows with NA values
data <- na.omit(data)

# Create target variable (Next day price)
data$NextDayPrice <- lead(data$AAPL.Adjusted, 1)

# Remove rows with NA values
data <- na.omit(data)

# Split data into training and testing sets
training_data <- data[data$Date < '2022-01-01',]
testing_data <- data[data$Date >= '2022-01-01',]

# Build the model
model <- randomForest(NextDayPrice ~ . -Date -AAPL.Adjusted, data = training_data, ntree = 500)

# Make predictions
predictions <- predict(model, newdata = testing_data)

# Display predictions
print(predictions)
