package main

import (
	"fmt"
	"net/http"
	"os"
	"path/filepath"
	"runtime"
	"time"

	"app/handler"

	"github.com/Sirupsen/logrus"
	"github.com/codegangsta/cli"
	"github.com/gorilla/mux"
	"github.com/spf13/viper"
)

var buildTimestamp = time.Now().Format(time.RFC3339)

func main() {
	app := cli.NewApp()
	app.Name = "demo app"
	app.Usage = "demo a simple application"
	app.Version = "1.0.0"

	app.Flags = []cli.Flag{
		cli.StringFlag{
			Name:   "config",
			Value:  "/etc/app/config",
			Usage:  "config file to use",
			EnvVar: "APP_CONFIG",
		},
	}

	app.Action = func(c *cli.Context) {
		// Load our app config
		configFile := c.String("config")
		viper.SetConfigName(filepath.Base(configFile))
		viper.AddConfigPath(filepath.Dir(configFile))
		viper.AutomaticEnv()
		if errCfg := viper.ReadInConfig(); errCfg != nil {
			logrus.WithFields(logrus.Fields{
				"configFile": configFile,
				"error":      errCfg,
			}).Fatal("unable to load config file")

			return
		}

		logrus.SetFormatter(&logrus.TextFormatter{})

		// get cores to use from config file
		ncpu := runtime.NumCPU()
		runtime.GOMAXPROCS(ncpu)
		logrus.WithFields(logrus.Fields{
			"ncpu": ncpu,
		}).Info("set GOMAXPROCS")

		logLevel := viper.GetString("log_level")
		level, errParse := logrus.ParseLevel(logLevel)
		if errParse != nil {
			logrus.WithFields(logrus.Fields{
				"error": errParse,
			}).Fatal("unable to parse log_level")

			return
		}
		logrus.SetLevel(level)
		logrus.WithFields(logrus.Fields{
			"log_level": logLevel,
		}).Info("set log level")

		// Routes consist of a path and a handler function.
		r := mux.NewRouter()
		setUpRouter(r)
		// Bind to a port and pass our router in
		httpPort := fmt.Sprintf(":%s", viper.GetString("port"))
		logrus.WithFields(logrus.Fields{
			"httpPort": httpPort,
		}).Info("starting http server")
		if err := http.ListenAndServe(httpPort, r); err != nil {
			logrus.WithFields(logrus.Fields{
				"error": err,
			}).Fatal("unable to start http server")

			return
		}
	}

	app.Run(os.Args)

}

func setUpRouter(r *mux.Router) {
	r.Handle("/", handler.DemoController{})

}
