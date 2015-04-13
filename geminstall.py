from subprocess import call

def install(f):
	with open(f) as gems:
		for g in gems:
			g = g.strip()
			call(["sudo gem install", g[0]])

if __name__ == '__main__':
	install('gems.txt')

call(["ls", "-l"])