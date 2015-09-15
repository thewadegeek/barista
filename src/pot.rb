# Defines the "Brewfile" configuration.

require 'json'

class Pot
  @@filePath = "Brewfile"
  @@parameters =  Hash.new

  # Set the member variables.
  def initialize(target)
    if (target == @@filePath)
      @configFile = File.read(target)
      @@parameters  = JSON.parse(@configFile)
    else
      if File.file?(target) then
        @@parameters['image'] = target
        # Parse file information.
        @fileContent = File.read(target)
        @baseInfo  = JSON.parse(@fileContent)

        # Get the complete path
        path = `pwd`

        @@parameters['toolchain'] = path.strip+'/.brew/toolchain/bin/'
        @@parameters['prefix'] = @baseInfo['prefix']
        @@parameters['sysroot'] = path.strip+'/.brew/toolchain/'+@@parameters['prefix']+'/sysroot/'
      end
    end

    # Create directory structure.
    Dir.mkdir('.brew') unless File.exists?('.brew')
    Dir.mkdir('.brew/toolchain/') unless File.exists?('.brew/toolchain/')

    # Pull the base FS image.
    system 'wget '+ @baseInfo['fs_base'] + ' -O .brew/base_image'

    # Pull the toolchain
    system 'wget '+ @baseInfo['toolchain'] + ' -O .brew/toolchain_archive'
    # Extract toolchain
    system 'tar -xf .brew/toolchain_archive -C .brew/toolchain/ > /dev/null 2>&1'
  end

  # Get all the projects currently in the Brew.
  def projects
    @@parameters['projects'] .each do |project|
      puts project['name']
    end
    return @@parameters['projects']
  end

  # Add a project to the Brew.
  def add_project(new_project)
    @@parameters['projects'].insert(-1, new_project)
  end

  # Save the Brew back to JSON format.
  def save()
    File.open(@@filePath,"w") do |fileHandle|
      fileHandle.write(JSON.pretty_generate(@@parameters))
    end
  end

end
