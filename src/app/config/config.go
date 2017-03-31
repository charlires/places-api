package config

type Configuration struct {
	APIVersion  string
	HTTPPort    int
	Environment string
	LogLevel    string
}

func (c *Configuration) IsDevelopment() bool {
	return c.Environment == "development"
}

func (c *Configuration) IsProduction() bool {
	return c.Environment == "production"
}

func (c *Configuration) IsStaging() bool {
	return c.Environment == "staging"
}

var Config *Configuration

func init() {
}
