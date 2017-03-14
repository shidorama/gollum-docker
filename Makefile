default: clone
	gollum --port 8080 --host localhost --config /wiki/config.rb --base-path /wiki /wiki/data

clone: ssl updater
	git clone ${GIT_REPO} /wiki/data
	git config --global push.default matching
	touch clone

updater:
	/usr/bin/crontab crontab
	touch updater

ssl:
	./ssl-check.ssh
	touch ssl

clean:
	rm ssl clone updater