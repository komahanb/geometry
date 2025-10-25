# Python Program for quick gmsh grid gen

import string,sys

def convert_pts_togmsh(inputfile,fout,startpoint, z):
        fin = open(inputfile, 'r')
        
	i=0
	x = []; y = [];
	
	lines = fin.readlines()

	for line in lines:
		# comments indicated by #
		if line[0] != '#' or line[0] != '':
			i=i+1
			data = string.split(line)
			x.append(float(data[0]))
			y.append(float(data[1]))
			#z.append(float(data[2]))

			n_lines = int(i)

        fin.close
        
	lc_name = "nac_lc" #"%s_lc" % filename[0:3]
	# Format
	# Point(1) = {0, 0, 0, lc};
	fout.write("%s = 0.1;\n" % lc_name)
	j = startpoint
	for i in range(n_lines):
		outputline  = "Point(%i) = { %8.8f, %8.8f, %8.8f, %s};\n " \
					      % (j,x[i],y[i],z,lc_name )
		j = j + 1
		fout.write(outputline)

	# gmsh bspline format	
	# Write out splinefit line
	fout.write("Spline(%i) = {%i:%i,%i};\n" \
		   % (startpoint,startpoint,startpoint+n_lines-1,startpoint))
        
	
def main():
  inputfile = sys.argv[1]
  fout = open(inputfile+".geo",'w')
  convert_pts_togmsh(inputfile,fout, 1000, 0.0)
  convert_pts_togmsh(inputfile,fout, 2000, 1.0)
  #convert_pts_togmsh(inputfile,fout, 5000, 5.0)
  fout.close
        
if __name__ == "__main__":
    main()
