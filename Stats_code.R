## AC
## 01/2022

# Documentation about plots
#   https://rpkgs.datanovia.com/ggpubr/reference/ggpaired.html
#   http://www.sthda.com/english/wiki/ggplot2-violin-plot-quick-start-guide-r-software-and-data-visualization
#   https://stackoverflow.com/questions/50202895/add-mean-value-on-boxplot-with-ggpubr

# *********************************** Paired Pre and Post - (Paired box plots)***********
# Ages
Pre <- read.csv("\\Rstudio_inputs\\age_pre.csv", header = T)
Post <- read.csv("\\Rstudio_inputs\\age_post.csv", header = T)

# Transitivity
Pre <- read.csv("\\Rstudio_inputs\\transitivity_pre.csv", header = T)
Post <- read.csv("\\Rstudio_inputs\\transitivity_post.csv", header = T)

# net_trans_sr
Pre <- read.csv("\\Rstudio_inputs\\net_trans_sr_pre.csv", header = T)
Post <- read.csv("\\Rstudio_inputs\\net_trans_sr_post.csv", header = T)

# net_cluster_mean_sr
Pre <- read.csv("\\Rstudio_inputs\\net_cluster_mean_sr_pre.csv", header = T)
Post <- read.csv("\\Rstudio_inputs\\net_cluster_mean_sr_post.csv", header = T)

# efficiency local
Pre <- read.csv("\\Rstudio_inputs\\efficiency_local_pre.csv", header = T)
Post <- read.csv("\\Rstudio_inputs\\efficiency_local_post.csv", header = T)

# efficiency global
Pre <- read.csv("\\Rstudio_inputs\\efficiency_global_pre.csv", header = T)
Post <- read.csv("\\Rstudio_inputs\\efficiency_global_post.csv", header = T)

# degrees
Pre <- read.csv("\\Rstudio_inputs\\degrees_pre.csv", header = T)
Post <- read.csv("\\Rstudio_inputs\\degrees_post.csv", header = T)

# clustering
Pre <- read.csv("\\Rstudio_inputs\\clustering_pre.csv", header = T)
Post <- read.csv("\\Rstudio_inputs\\clustering_post.csv", header = T)

# betweenness
Pre <- read.csv("\\Rstudio_inputs\\betweenness_pre.csv", header = T)
Post <- read.csv("\\Rstudio_inputs\\betweenness_post.csv", header = T)

# strength
Pre <- read.csv("\\Rstudio_inputs\\strength_pre.csv", header = T)
Post <- read.csv("\\Rstudio_inputs\\strength_post.csv", header = T)

d <- data.frame(Pre = Pre, Post = Post)
p1 <- ggpaired(d, cond1 = "Pre", cond2 = "Post", line.color="gray", line.size=0.4, palette = "npg", fill="condition") + labs(x="Condition", y = "Age [years]")


# compute the difference
d <- Pre - Post
# Shapiro-Wilk normality test for the differences
shapiro.test(d$Pre)

shapiro.test(Pre$Pre)
shapiro.test(Post$Post)

# Normal
t.test(Pre$Pre, Post$Post, paired = TRUE, alternative = "two.sided")
p1 + stat_compare_means(method='t.test', paired=T, label="p") # In case you want to print the p-value inside the graph

# No normal
wilcox.test(Pre$Pre, Post$Post, paired = TRUE, alternative = "two.sided")
p1 + stat_compare_means(method='wilcox.test', paired=T, label="p") # In case you want to print the p-value inside the graph


# *********************************** Two samples Pre and Post (not paired) - Violin plots ***********

# Transitivity
d <- read.csv("\\Rstudio_inputs\\transitivity_both.csv", header = T)

# net_trans_sr
d <- read.csv("\\Rstudio_inputs\\net_trans_sr_both.csv", header = T)

# net_cluster_mean_sr
d <- read.csv("\\Rstudio_inputs\\net_cluster_mean_sr_both.csv", header = T)

# efficiency local
d <- read.csv("\\Rstudio_inputs\\efficiency_local_both.csv", header = T)

# efficiency global
d <- read.csv("\\Rstudio_inputs\\efficiency_global_both.csv", header = T)

# degrees
d <- read.csv("\\Rstudio_inputs\\degrees_both.csv", header = T)

# clustering
d <- read.csv("\\Rstudio_inputs\\clustering_both.csv", header = T)

# betweenness
d <- read.csv("\\Rstudio_inputs\\betweenness_both.csv", header = T)

# strength
d <- read.csv("\\Rstudio_inputs\\strength_both.csv", header = T)



# Normality test p>0.05
# Shapiro-Wilk normality test
with(d, shapiro.test(Value[Condition == "Pre"]))
# Shapiro-Wilk normality test
with(d, shapiro.test(Value[Condition == "Post"]))

# Normal
t.test(Value ~ Condition, data = d, var.equal = TRUE)

# Non-normal
wilcox.test(Value ~ Condition, data = d, exact = FALSE)


dp <- ggplot(d, aes(x=Condition, y=Value, fill=Condition)) + 
  geom_violin(trim=FALSE)+
  geom_boxplot(width=0.1, fill="white")+
  labs(x="Condition", y = "Value")
dp + theme_classic()
