require 'rake'
require 'rake/clean'
require 'tmpdir'

DATA_DIR = "/home/chris/MRI/FacePlaceObject/data"
SUBJECT_INDEX = ('01'..'10').to_a
ROI_ORIG_HASH = {
  'face': SUBJECT_INDEX.collect do |s|
      File.join(DATA_DIR,'roi','face','afni','orig',s,'facesystem+orig.HEAD')
    end,
  'place': SUBJECT_INDEX.collect do |s|
      File.join(DATA_DIR,'roi','place','afni','orig',s,'placesystem+orig.HEAD')
    end,
  'object': SUBJECT_INDEX.collect do |s|
      File.join(DATA_DIR,'roi','object','afni','orig',s,'objectsystem+orig.HEAD')
    end
}

WARP_REFERENCE = [
  "#{DATA_DIR}/T1/tlrc/01mnd_anat_train_al_ns+tlrc.HEAD",
  "#{DATA_DIR}/raw/02/T1/02mnd_anat_train_al+tlrc.HEAD",
  "#{DATA_DIR}/raw/03/T1/03mnd_anat_train_al+tlrc.HEAD",
  "#{DATA_DIR}/raw/04/T1/04mnd_anat_train_al+tlrc.HEAD",
  "#{DATA_DIR}/raw/05/T1/05mnd_anat_train_al+tlrc.HEAD",
  "#{DATA_DIR}/raw/06/T1/06mnd_anat_train_al+tlrc.HEAD",
  "#{DATA_DIR}/T1/tlrc/07mnd_anat_train_al_ns+tlrc.HEAD",
  "#{DATA_DIR}/T1/tlrc/08mnd_anat_train_al_ns+tlrc.HEAD",
  "#{DATA_DIR}/T1/tlrc/09mnd_anat_train_al_ns+tlrc.HEAD",
  "#{DATA_DIR}/raw/10/T1/10mnd_anat_train_al+tlrc.HEAD"
]

DATA_REFERENCE = [
  "#{DATA_DIR}/raw/01/func/01train_TR5+orig.HEAD",
  "#{DATA_DIR}/raw/02/func/02train_TR5+orig.HEAD",
  "#{DATA_DIR}/raw/03/func/03train_TR5+orig.HEAD",
  "#{DATA_DIR}/raw/04/func/04train_TR5+orig.HEAD",
  "#{DATA_DIR}/raw/05/func/05train_TR5+orig.HEAD",
  "#{DATA_DIR}/raw/06/func/06train_TR5+orig.HEAD",
  "#{DATA_DIR}/raw/07/func/07train_TR5+orig.HEAD",
  "#{DATA_DIR}/raw/08/func/08train_TR5+orig.HEAD",
  "#{DATA_DIR}/raw/09/func/09train_TR5+orig.HEAD",
  "#{DATA_DIR}/raw/10/func/10train_TR5+orig.HEAD"
]

CORTEX_ORIG = SUBJECT_INDEX.collect do |s|
  File.join(DATA_DIR,'mask','handmade','funcres',"mask#{s}+orig.HEAD")
end

WHOLEBRAIN_TARGETS = SUBJECT_INDEX.collect do |s|
  File.join(DATA_DIR,'mask','handmade','funcres',"mask_#{s}_wholebrain+orig.txt")
end

WHOLEBRAIN_DATA = SUBJECT_INDEX.collect do |s|
  File.join(DATA_DIR,'mask','handmade','funcres',"data_#{s}_wholebrain_TR5+orig.txt")
end

ROI_TARGETS = {
  'face': SUBJECT_INDEX.collect do |s|
    File.join(DATA_DIR,'mask','handmade','funcres',"mask_#{s}_roi_face+orig.txt")
  end,
  'place': SUBJECT_INDEX.collect do |s|
    File.join(DATA_DIR,'mask','handmade','funcres',"mask_#{s}_roi_place+orig.txt")
  end,
  'object': SUBJECT_INDEX.collect do |s|
    File.join(DATA_DIR,'mask','handmade','funcres',"mask_#{s}_roi_object+orig.txt")
  end
}

LESION_TARGETS = {
  'face': SUBJECT_INDEX.collect do |s|
    File.join(DATA_DIR,'mask','handmade','funcres',"mask_#{s}_lesion_face+orig.txt")
  end,
  'place': SUBJECT_INDEX.collect do |s|
    File.join(DATA_DIR,'mask','handmade','funcres',"mask_#{s}_lesion_place+orig.txt")
  end,
  'object': SUBJECT_INDEX.collect do |s|
    File.join(DATA_DIR,'mask','handmade','funcres',"mask_#{s}_lesion_object+orig.txt")
  end,
  'face+place': SUBJECT_INDEX.collect do |s|
    File.join(DATA_DIR,'mask','handmade','funcres',"mask_#{s}_lesion_faceplace+orig.txt")
  end,
  'face+place+object': SUBJECT_INDEX.collect do |s|
    File.join(DATA_DIR,'mask','handmade','funcres',"mask_#{s}_lesion_faceplaceobject+orig.txt")
  end
}

WHOLEBRAIN_TARGETS_TLRC = SUBJECT_INDEX.collect do |s|
  File.join(DATA_DIR,'mask','handmade','funcres',"mask_#{s}_wholebrain+tlrc.txt")
end

ROI_TARGETS_TLRC = {
  'face': SUBJECT_INDEX.collect do |s|
    File.join(DATA_DIR,'mask','handmade','funcres',"mask_#{s}_roi_face+tlrc.txt")
  end,
  'place': SUBJECT_INDEX.collect do |s|
    File.join(DATA_DIR,'mask','handmade','funcres',"mask_#{s}_roi_place+tlrc.txt")
  end,
  'object': SUBJECT_INDEX.collect do |s|
    File.join(DATA_DIR,'mask','handmade','funcres',"mask_#{s}_roi_object+tlrc.txt")
  end
}

LESION_TARGETS_TLRC = {
  'face': SUBJECT_INDEX.collect do |s|
    File.join(DATA_DIR,'mask','handmade','funcres',"mask_#{s}_lesion_face+tlrc.txt")
  end,
  'place': SUBJECT_INDEX.collect do |s|
    File.join(DATA_DIR,'mask','handmade','funcres',"mask_#{s}_lesion_place+tlrc.txt")
  end,
  'object': SUBJECT_INDEX.collect do |s|
    File.join(DATA_DIR,'mask','handmade','funcres',"mask_#{s}_lesion_object+tlrc.txt")
  end,
  'face+place': SUBJECT_INDEX.collect do |s|
    File.join(DATA_DIR,'mask','handmade','funcres',"mask_#{s}_lesion_faceplace+tlrc.txt")
  end,
  'face+place+object': SUBJECT_INDEX.collect do |s|
    File.join(DATA_DIR,'mask','handmade','funcres',"mask_#{s}_lesion_faceplaceobject+tlrc.txt")
  end
}
LESION_TARGETS_TLRC_AFNI = {
  'face': SUBJECT_INDEX.collect do |s|
    File.join(DATA_DIR,'mask','handmade','funcres',"mask_#{s}_lesion_face+tlrc.HEAD")
  end,
  'place': SUBJECT_INDEX.collect do |s|
    File.join(DATA_DIR,'mask','handmade','funcres',"mask_#{s}_lesion_place+tlrc.HEAD")
  end,
  'object': SUBJECT_INDEX.collect do |s|
    File.join(DATA_DIR,'mask','handmade','funcres',"mask_#{s}_lesion_object+tlrc.HEAD")
  end,
  'face+place': SUBJECT_INDEX.collect do |s|
    File.join(DATA_DIR,'mask','handmade','funcres',"mask_#{s}_lesion_faceplace+tlrc.HEAD")
  end,
  'face+place+object': SUBJECT_INDEX.collect do |s|
    File.join(DATA_DIR,'mask','handmade','funcres',"mask_#{s}_lesion_faceplaceobject+tlrc.HEAD")
  end
}
LESION_TARGETS_ORIG_AFNI = {
  'face': SUBJECT_INDEX.collect do |s|
    File.join(DATA_DIR,'mask','handmade','funcres',"mask_#{s}_lesion_face+orig.HEAD")
  end,
  'place': SUBJECT_INDEX.collect do |s|
    File.join(DATA_DIR,'mask','handmade','funcres',"mask_#{s}_lesion_place+orig.HEAD")
  end,
  'object': SUBJECT_INDEX.collect do |s|
    File.join(DATA_DIR,'mask','handmade','funcres',"mask_#{s}_lesion_object+orig.HEAD")
  end,
  'face+place': SUBJECT_INDEX.collect do |s|
    File.join(DATA_DIR,'mask','handmade','funcres',"mask_#{s}_lesion_faceplace+orig.HEAD")
  end,
  'face+place+object': SUBJECT_INDEX.collect do |s|
    File.join(DATA_DIR,'mask','handmade','funcres',"mask_#{s}_lesion_faceplaceobject+orig.HEAD")
  end
}


WHOLEBRAIN_DATA.zip(CORTEX_ORIG,DATA_REFERENCE).each do |data_dump,cortex,data_in|
  file data_dump => [cortex,data_in] do
    sh("3dmaskdump -mask #{cortex} -index -xyz -o #{data_dump} #{data_in}")
  end
end

WHOLEBRAIN_TARGETS.zip(CORTEX_ORIG,WARP_REFERENCE).each do |target_dump,cortex,warp|
  target_dump_tlrc = target_dump.sub('+orig','+tlrc')
  file target_dump => cortex do
    sh("3dmaskdump -mask #{cortex} -index -xyz -o #{target_dump} #{cortex}")
  end
  file target_dump_tlrc => target_dump do
    Dir.mktmpdir do |dir|
      xyz1D = File.join(dir, 'xyz.1D')
      sh("cut -d' ' -f5-7 #{target_dump} > #{xyz1D}")
      sh("Vecwarp -apar #{warp} -forward -input #{xyz1D} -output #{target_dump_tlrc}")
    end
  end
  CLEAN.push(target_dump_tlrc)
  CLOBBER.push(target_dump)
end

# This feels needlessly complex, but here are what I believe to be the
# complications:
#
# - If I need to combine ROIs, I want to do that combination in a temporary
# directory.
#
# - If the creation of a temporary directory happens outside of the file task
# definition, the temporary files will have disappeared by the time they are
# needed.
#
# - Things should be done differently depending on whether combination is
# required at all. It affects whether and how items are grouped into lists,
# which affects looping and coordination among different elements.
#
ROI_TARGETS.each do |systems,target_list|
  system_list = systems.to_s.split('+').collect {|s| s.to_sym}
  if system_list.length > 1 then
    roi_lol = ROI_ORIG_HASH.select {|key,value| system_list.include? key}.values.transpose
    target_list.zip(CORTEX_ORIG,roi_lol,WARP_REFERENCE).each do |target_dump,cortex,roi_pieces,warp|
      target = target_dump.sub('.txt','.HEAD')
      target_dump_tlrc = target_dump.sub('+orig','+tlrc')
      target_prefix = target.split('+').first
      file target => [cortex] + roi_pieces do
        Dir.mktmpdir do |dir|
          combined_roi = File.join(dir,'combined_roi+orig.HEAD')
          combined_roi_prefix = combined_roi.split('+').first
          slots = ('-a'..'-z').to_a.slice(0,roi_pieces.length)
          expr = ('a'..'z').to_a.slice(0,roi_pieces.length).join('+')
          inputs = slots.zip(roi_pieces).flatten.join(' ')
          sh("3dcalc #{inputs} -expr '#{expr}' -prefix #{combined_roi_prefix}")
          inputs = "-a #{combined_roi} -b #{cortex}"
          expr = "a*b"
          sh("3dcalc #{inputs} -expr '#{expr}' -prefix #{target_prefix}")
        end
      end
      file target_dump => target do
        sh("3dmaskdump -mask #{target} -index -xyz -o #{target_dump} #{target}")
      end
      file target_dump_tlrc => target_dump do
        Dir.mktmpdir do |dir|
          xyz1D = File.join(dir, 'xyz.1D')
          sh("cut -d' ' -f5-7 #{target_dump} > #{xyz1D}")
          sh("Vecwarp -apar #{warp} -forward -input #{xyz1D} -output #{target_dump_tlrc}")
        end
      end
      CLEAN.push(target_dump_tlrc)
      CLOBBER.push(target_dump)
      CLOBBER.push(target)
      CLOBBER.push(target.sub(".HEAD",".BRIK"))
      CLOBBER.push(target.sub(".HEAD",".BRIK.gz"))
    end
  else
    system = system_list.first
    roi_list = ROI_ORIG_HASH[system]
    target_list.zip(CORTEX_ORIG,roi_list,WARP_REFERENCE).each do |target_dump,cortex,roi,warp|
      target = target_dump.sub('.txt','.HEAD')
      target_dump_tlrc = target_dump.sub('+orig','+tlrc')
      target_prefix = target.split('+').first
      file target => [cortex,roi] do
        inputs = "-a #{roi} -b #{cortex}"
        expr = "a*b"
        sh("3dcalc #{inputs} -expr '#{expr}' -prefix #{target_prefix}")
      end
      file target_dump => target do
        sh("3dmaskdump -mask #{target} -index -xyz -o #{target_dump} #{target}")
      end
      file target_dump_tlrc => target_dump do
        Dir.mktmpdir do |dir|
          xyz1D = File.join(dir, 'xyz.1D')
          sh("cut -d' ' -f5-7 #{target_dump} > #{xyz1D}")
          sh("Vecwarp -apar #{warp} -forward -input #{xyz1D} -output #{target_dump_tlrc}")
        end
      end
      CLEAN.push(target_dump_tlrc)
      CLOBBER.push(target_dump)
      CLOBBER.push(target)
      CLOBBER.push(target.sub(".HEAD",".BRIK"))
      CLOBBER.push(target.sub(".HEAD",".BRIK.gz"))
    end
  end
end

LESION_TARGETS.each do |systems,target_list|
  system_list = systems.to_s.split('+').collect {|s| s.to_sym}
  if system_list.length > 1 then
    roi_lol = ROI_ORIG_HASH.select {|key,value| system_list.include? key}.values.transpose
    target_list.zip(CORTEX_ORIG,roi_lol,WARP_REFERENCE).each do |target_dump,cortex,roi_pieces,warp|
      target = target_dump.sub('.txt','.HEAD')
      target_dump_tlrc = target_dump.sub('+orig','+tlrc')
      target_prefix = target.split('+').first
      file target => [cortex] + roi_pieces do
        Dir.mktmpdir do |dir|
          combined_roi = File.join(dir,'combined_roi+orig.HEAD')
          combined_roi_prefix = combined_roi.split('+').first
          slots = ('-a'..'-z').to_a.slice(0,roi_pieces.length)
          expr = ('a'..'z').to_a.slice(0,roi_pieces.length).join('+')
          inputs = slots.zip(roi_pieces).flatten.join(' ')
          sh("3dcalc #{inputs} -expr '#{expr}' -prefix #{combined_roi_prefix}")
          inputs = "-a #{combined_roi} -b #{cortex}"
          expr = "not(a)*b"
          sh("3dcalc #{inputs} -expr '#{expr}' -prefix #{target_prefix}")
        end
      end
      file target_dump => target do
        sh("3dmaskdump -mask #{target} -index -xyz -o #{target_dump} #{target}")
      end
      file target_dump_tlrc => target_dump do
        Dir.mktmpdir do |dir|
          xyz1D = File.join(dir, 'xyz.1D')
          sh("cut -d' ' -f5-7 #{target_dump} > #{xyz1D}")
          sh("Vecwarp -apar #{warp} -forward -input #{xyz1D} -output #{target_dump_tlrc}")
        end
      end
      CLEAN.push(target_dump_tlrc)
      CLOBBER.push(target_dump)
      CLOBBER.push(target)
      CLOBBER.push(target.sub(".HEAD",".BRIK"))
      CLOBBER.push(target.sub(".HEAD",".BRIK.gz"))
    end
  else
    system = system_list.first
    roi_list = ROI_ORIG_HASH[system]
    target_list.zip(CORTEX_ORIG,roi_list,WARP_REFERENCE).each do |target_dump,cortex,roi,warp|
      target = target_dump.sub('.txt','.HEAD')
      target_dump_tlrc = target_dump.sub('+orig.txt','+tlrc.txt')
      target_prefix = target.split('+').first
      file target => [cortex,roi] do
        inputs = "-a #{roi} -b #{cortex}"
        expr = "not(a)*b"
        sh("3dcalc #{inputs} -expr '#{expr}' -prefix #{target_prefix}")
      end
      file target_dump => target do
        sh("3dmaskdump -mask #{target} -index -xyz -o #{target_dump} #{target}")
      end
      file target_dump_tlrc => target_dump do
        Dir.mktmpdir do |dir|
          xyz1D = File.join(dir, 'xyz.1D')
          sh("cut -d' ' -f5-7 #{target_dump} > #{xyz1D}")
          sh("Vecwarp -apar #{warp} -forward -input #{xyz1D} -output #{target_dump_tlrc}")
        end
      end
      CLEAN.push(target_dump_tlrc)
      CLOBBER.push(target_dump)
      CLOBBER.push(target)
      CLOBBER.push(target.sub(".HEAD",".BRIK"))
      CLOBBER.push(target.sub(".HEAD",".BRIK.gz"))
    end
  end
end

LESION_TARGETS_TLRC_AFNI.each do |systems,target_list|
  source_list = LESION_TARGETS_ORIG_AFNI[systems]
  target_list.zip(source_list,WARP_REFERENCE).each do |target,source,warp|
    file target => [source,warp] do
      sh("adwarp -apar #{warp} -dpar #{source}")
    end
  end
end
task :all => WHOLEBRAIN_TARGETS + ROI_TARGETS.values.flatten + LESION_TARGETS.values.flatten
task :points_to_tlrc => WHOLEBRAIN_TARGETS_TLRC + ROI_TARGETS_TLRC.values.flatten + LESION_TARGETS_TLRC.values.flatten
task :TR5_dump => WHOLEBRAIN_DATA
task :rewarp => LESION_TARGETS_TLRC_AFNI.values.flatten
task :default => :all
