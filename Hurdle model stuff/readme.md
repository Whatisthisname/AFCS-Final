Hi David and Xander, here is some information on the Hurdle model and using the mean to predict.


The idea behind this model (apparently known as a "Hurdle model") is to use two separate models for every single product. For a chosen product, expand the expected sales at time $t$ into

$$\mathbb{E}[sales_t] = \mathbb{P}(sales_t = 0) \cdot \mathbb{E}[sales_t \mid sales_t = 0] + \mathbb{P}(sales_t > 0) \cdot\mathbb{E}[sales_t \mid sales_t > 0]$$
$$ = \mathbb{P}(sales_t = 0) \cdot 0 + \mathbb{P}(sales_t > 0)\cdot \mathbb{E}[sales_t \mid sales_t > 0]$$
$$ = \mathbb{P}(sales_t > 0) \cdot\mathbb{E}[sales_t \mid sales_t > 0]$$


Thus, there is one model predicting whether anything happens at all (the "occurrence model"). It is generating, for each timestamp, the value of $\mathbb{P}(sales_t > 0)$., the probility that there are more than zero sales.
This model is implemented as a binary classifier (logistic regression) using a "generalized linear model", with the `glm` function. It just has to learn to guess whether more than zero sales happened that day for that product.

The second model (the "size model") is predicting $\mathbb{E}[sales_t \mid sales_t > 0]$, the conditional mean of the amount of sales, given that we know that there are more than zero sales. This model is trained only on days in which there were more than zero sales, thus yielding the conditional model. This is also implemented with `glm`, with a poisson model for the # of sales.

To generate predictions, we simply multiply the output of the occurrence model with the output of the size model, which, as we showed mathematically, should give the expected amount of sales.

Both the occurrence and size model use only the `day of week` and the `sell_price` at time $t$ as their inputs, so they are quite simple.
I chose not to use a lagged `sell_price` as input because sell price generally doesn't change.

The models train quite fast, within 5 minutes for all 800-ish products, producing no errors. Checking on the validation set (by using the sell-price predicted into the future using NAIVE models), it achieves a RMSE and MAE of 3.19 and 1.56, respectively. When just using the mean of the sales to predict , we get 3.42 and 1.63 for RMSE and MAE, so the hurdle model is slightly stronger.

We might not want to include the following information, but when trained on the train+validation set and evaluated on the evaluation set, it achieves RMSE and MAE of 3.73 and 1.73. This might be interesting to show in hindsight, as long we don't optimize on it.
In this case, when using just the mean, we get RMSE 3.64 and MAE 1.68, which is slightly better.

I have no plots to show for this 