# T2 frozen raw-input replay. Requires R >= 4.0 and jsonlite only.
# No network, credentials, API packages, or writes are used.
library(jsonlite)

needed <- c("inputs/treasury/buybacks_operations.json", "inputs/fred/DGS10.csv",
            "inputs/fred/DGS30.csv", "inputs/japan/jgbcme_jgbcme_all.csv",
            "inputs/japan/jgbcme_jgbcme.csv", "inputs/policy/fed-2026-09-16-statement-excerpt.txt")
stopifnot(all(file.exists(needed)))
read_fred <- function(series) {
  x <- read.csv(file.path("inputs/fred", paste0(series, ".csv")), stringsAsFactors = FALSE)
  data.frame(date = as.Date(x$date), value = as.numeric(x$value))
}
read_jgb <- function(path) {
  rows <- grep("^[0-9]{4}/[0-9]{1,2}/[0-9]{1,2},", readLines(path, warn = FALSE, encoding = "latin1"),
               value = TRUE, useBytes = TRUE)
  fields <- strsplit(rows, ",", fixed = TRUE)
  x <- data.frame(date = suppressWarnings(as.Date(vapply(fields, `[`, "", 1), format = "%Y/%m/%d")),
                  jgb10 = suppressWarnings(as.numeric(vapply(fields, `[`, "", 11))),
                  jgb30 = suppressWarnings(as.numeric(vapply(fields, `[`, "", 15))))
  x[complete.cases(x), ]
}
raw <- fromJSON("inputs/treasury/buybacks_operations.json")$data
ops <- suppressWarnings(data.frame(date = as.Date(raw$operation_date), type = raw$security_type,
                                   bucket = raw$maturity_bucket, accepted = as.numeric(raw$total_par_amt_accepted),
                                   maximum = as.numeric(raw$max_par_amt_redeemed)))
long <- ops[ops$type == "Nominal Coupons" & ops$bucket %in% c("10Y to 20Y", "20Y to 30Y", "10Y to 30Y") &
              ops$date > as.Date("2026-09-02") & ops$date <= as.Date("2026-11-04"), ]
long <- long[order(long$date), ]
stopifnot(nrow(long) == 3L, identical(as.character(long$date), c("2026-09-10", "2026-09-24", "2026-10-01")),
          all(long$accepted == c(5.187e9, 4.078e9, 6e9)), all(long$maximum == 6e9))
d10 <- read_fred("DGS10"); d30 <- read_fred("DGS30")
jgb <- unique(rbind(read_jgb("inputs/japan/jgbcme_jgbcme_all.csv"), read_jgb("inputs/japan/jgbcme_jgbcme.csv")))
us <- merge(d30, d10, by = "date", suffixes = c("_30", "_10")); common <- merge(us, jgb, by = "date")
diff_bp <- (common$value_30 - common$value_10 - common$jgb30 + common$jgb10) * 100
mean_at <- function(day) { i <- match(as.Date(day), common$date); mean(diff_bp[(i - 9):i]) }
baseline <- mean_at("2026-09-02"); latest <- mean(tail(diff_bp, 10))
stopifnot(abs(baseline + 63.24) < 1e-8, abs(latest + 71.33) < 1e-8,
          abs(latest - baseline + 8.09) < 1e-8, max(common$date) == as.Date("2026-10-02"))
mod_duration <- function(coupon, yield) {
  t <- seq_len(20); cash <- rep(coupon / 200 * 100, 20); cash[20] <- cash[20] + 100; rate <- yield / 200
  price <- sum(cash / (1 + rate)^t); (sum(t * cash / (1 + rate)^t) / price / 2) / (1 + rate)
}
duration <- mod_duration(4.625, 5.28); illustration <- sum(long$accepted) * c(9, 15) / duration / 800e9 * 25
stopifnot(abs(duration - 7.851538709) < 1e-8, max(abs(illustration - c(0.546807627, 0.911346045))) < 1e-8)
policy <- readLines("inputs/policy/fed-2026-09-16-statement-excerpt.txt", warn = FALSE)
stopifnot(identical(policy[1], "September 16, 2026"),
          any(grepl("raise the target range for the federal funds rate by 1/4 percentage point to 3-3/4 to 4 percent", policy, fixed = TRUE)))
cat(sprintf("PASS: gross long-nominal purchases $%.3fB; slope %.2f -> %.2fbp (%.2fbp); duration %.9f; illustrative scale %.9f-%.9fbp; policy receipt verifies 25bp hike.\n",
            sum(long$accepted) / 1e9, baseline, latest, latest - baseline, duration, illustration[1], illustration[2]))
