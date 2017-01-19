require 'rake'
require 'rake/clean'
require 'tmpdir'

DATA_DIR = "/home/chris/MRI/FacePlaceObject/data"
SUBJECT_INDEX = ('01'..'10').to_a
SYSTEM_INDEX = %w(face place object)
SYSTEM_KEYS = %i(face place object)
NATIVE_ANAT = [
  "#{DATA_DIR}/raw/01/T1/01mnd_anat_train_al+orig.HEAD",
  "#{DATA_DIR}/raw/02/T1/02mnd_anat_train_al+orig.HEAD",
  "#{DATA_DIR}/raw/03/T1/03mnd_anat_train_al+orig.HEAD",
  "#{DATA_DIR}/raw/04/T1/04mnd_anat_train_al+orig.HEAD",
  "#{DATA_DIR}/raw/05/T1/05mnd_anat_train_al+orig.HEAD",
  "#{DATA_DIR}/raw/06/T1/06mnd_anat_train_al+orig.HEAD",
  "#{DATA_DIR}/raw/07/T1/07mnd_anat_train_al+orig.HEAD",
  "#{DATA_DIR}/raw/08/T1/08mnd_anat_train_al+orig.HEAD",
  "#{DATA_DIR}/raw/09/T1/09mnd_anat_train_al+orig.HEAD",
  "#{DATA_DIR}/raw/10/T1/10mnd_anat_train_al+orig.HEAD"
]
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

GRID_REFERENCE = [
  "#{DATA_DIR}/mask/handmade/funcres/mask01+orig.HEAD",
  "#{DATA_DIR}/mask/handmade/funcres/mask02+orig.HEAD",
  "#{DATA_DIR}/mask/handmade/funcres/mask03+orig.HEAD",
  "#{DATA_DIR}/mask/handmade/funcres/mask04+orig.HEAD",
  "#{DATA_DIR}/mask/handmade/funcres/mask05+orig.HEAD",
  "#{DATA_DIR}/mask/handmade/funcres/mask06+orig.HEAD",
  "#{DATA_DIR}/mask/handmade/funcres/mask07+orig.HEAD",
  "#{DATA_DIR}/mask/handmade/funcres/mask08+orig.HEAD",
  "#{DATA_DIR}/mask/handmade/funcres/mask09+orig.HEAD",
  "#{DATA_DIR}/mask/handmade/funcres/mask10+orig.HEAD"
]

ROI_REFERENCE = {
  'face': [
    "#{DATA_DIR}/roi/face/afni/tlrc/rh.facesystem+tlrc.HEAD",
    "#{DATA_DIR}/roi/face/afni/tlrc/lh.facesystem+tlrc.HEAD"
  ],
  'place': [
    "#{DATA_DIR}/roi/place/afni/tlrc/rh.placesystem+tlrc.HEAD",
    "#{DATA_DIR}/roi/place/afni/tlrc/lh.placesystem+tlrc.HEAD"
  ],
  'object': [
    "#{DATA_DIR}/roi/object/afni/tlrc/rh.objectsystem+tlrc.HEAD",
    "#{DATA_DIR}/roi/object/afni/tlrc/lh.objectsystem+tlrc.HEAD"
  ]
}

ROI_TARGET = {
  'face': SUBJECT_INDEX.collect do |subject|
    File.join(DATA_DIR,'roi','face','afni','orig',subject,'facesystem+orig.HEAD')
  end,
  'place': SUBJECT_INDEX.collect do |subject|
    File.join(DATA_DIR,'roi','place','afni','orig',subject,'placesystem+orig.HEAD')
  end,
  'object': SUBJECT_INDEX.collect do |subject|
    File.join(DATA_DIR,'roi','object','afni','orig',subject,'objectsystem+orig.HEAD')
  end
}

ROI_TARGET_REWARP = {
  'face': SUBJECT_INDEX.collect do |subject|
    File.join(DATA_DIR,'roi','face','afni','orig',subject,'facesystem+tlrc.HEAD')
  end,
  'place': SUBJECT_INDEX.collect do |subject|
    File.join(DATA_DIR,'roi','place','afni','orig',subject,'placesystem+tlrc.HEAD')
  end,
  'object': SUBJECT_INDEX.collect do |subject|
    File.join(DATA_DIR,'roi','object','afni','orig',subject,'objectsystem+tlrc.HEAD')
  end
}


SYSTEM_INDEX.each do |system|
  SUBJECT_INDEX.each do |subject|
    directory File.join(DATA_DIR,'roi',system,'afni','orig',subject)
  end
end

SUBJECT_DIR_BY_SYSTEM = {
  face: SUBJECT_INDEX.collect do |subject|
    File.join(DATA_DIR,'roi','face','afni','orig',subject)
  end,
  place: SUBJECT_INDEX.collect do |subject|
    File.join(DATA_DIR,'roi','place','afni','orig',subject)
  end,
  object: SUBJECT_INDEX.collect do |subject|
    File.join(DATA_DIR,'roi','object','afni','orig',subject)
  end
}

full_list = []
SYSTEM_KEYS.each do |system|
  roi_pieces = ROI_REFERENCE[system]
  target_list = ROI_TARGET[system]
  subject_dir_list = SUBJECT_DIR_BY_SYSTEM[system]
  target_list.zip(WARP_REFERENCE,GRID_REFERENCE,subject_dir_list).each do |target,warp,grid,subject|
    target_prefix = target.split('+').first
    # target_prefix = File.join(subject,File.basename(roi, "+tlrc.HEAD"))
    # target = File.join(subject,File.basename(roi))
    file target => [warp, grid, subject] do
      Dir.mktmpdir do |dir|
        combined_roi = File.join(dir,'combined_roi+tlrc.HEAD')
        combined_roi_prefix = combined_roi.split('+').first
        slots = ('-a'..'-z').to_a.slice(0,roi_pieces.length)
        expr = ('a'..'z').to_a.slice(0,roi_pieces.length).join('+')
        inputs = slots.zip(roi_pieces).flatten.join(' ')
        sh("3dcalc #{inputs} -expr '#{expr}' -prefix #{combined_roi_prefix}")
        sh("3dfractionize -template #{grid} -input #{combined_roi} -warp #{warp} -clip 0.2 -prefix #{target_prefix}")
      end
    end
    full_list.push(target)
    CLOBBER.push(target)
    CLOBBER.push(target.sub(".HEAD",".BRIK"))
    CLOBBER.push(target.sub(".HEAD",".BRIK.gz"))
  end
end

SYSTEM_KEYS.each do |system|
  target_list = ROI_TARGET_REWARP[system]
  source_list = ROI_TARGET[system]
  target_list.zip(source_list,WARP_REFERENCE).each do |target,source,warp|
    file target => [source,warp] do
      sh("adwarp -apar #{warp} -dpar #{source}")
    end
    CLOBBER.push(target)
    CLOBBER.push(target.sub(".HEAD",".BRIK"))
    CLOBBER.push(target.sub(".HEAD",".BRIK.gz"))
  end
end

task :default => full_list
#
# This is technically broken: if the symlinks exist already, this will error out.
task :symlinks => SUBJECT_INDEX+NATIVE_ANAT do
  NATIVE_ANAT.zip(SUBJECT_INDEX).each do |anat,subject|
    Dir.chdir(subject) do
      sh("ln -s #{anat} .")
      if File.exist? anat.sub(".HEAD",".BRIK") then
        sh("ln -s #{anat.sub(".HEAD",".BRIK")} .")
      else
        sh("ln -s #{anat.sub(".HEAD",".BRIK.gz")} .")
      end
    end
    CLOBBER.push(target)
    CLOBBER.push(File.join(subject,anat.sub(".HEAD",".BRIK")))
    CLOBBER.push(File.join(subject,anat.sub(".HEAD",".BRIK.gz")))
  end
end

task :rewarp => ROI_TARGET_REWARP.values.flatten
