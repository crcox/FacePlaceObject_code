require 'rake'
require 'rake/clean'
require 'tmpdir'
require File.join(ENV['HOME'],'src','FacePlaceObject_code','rake','methods')

HOME = ENV['HOME']
XYZ_ORIENT = ENV.fetch('XYZ_ORIENT') {'RAI'} # order of xyz coordinates in txt files.
VOXDIM = ENV.fetch('VOXDIM') {3} # when applying a warp, this defines the voxelsize (in mm) for the warped data
_BLURFWHM = ENV.fetch('BLURFWHM') {4}
BLURFWHM = _BLURFWHM.to_i
THRESHOLD = ENV.fetch('threshold') {'q05'} # q controls FDR corrected p
DATA_DIR = ENV.fetch('DATA_DIR') {"#{HOME}/MRI/FacePlaceObject/data"}
SHARED_ATLAS = ENV.fetch('SHARED_ATLAS') {"#{HOME}/MRI/Manchester/data/CommonBrains/MNI_EPI_funcRes.nii"}
SHARED_ATLAS_TLRC = ENV.fetch('SHARED_ATLAS_TLRC') {"#{HOME}/MRI/Manchester/data/CommonBrains/TT_N27_funcres.nii"}
SPEC_BOTH = "#{HOME}/suma_TT_N27/TT_N27_both.spec"
SURFACE_VOLUME = "./TT_N27_SurfVol.nii"

# INDEXES
CATEGORY_INDEX = ['faces','places','objects']
SUBJECT_INDEX = ('01'..'10').to_a
RADII_INDEX = ['06','09','12','15']
#CVSUBSET = ENV.fetch('CVSUBSET').split {CROSSVALIDATION_INDEX}

dir_list = []
%w(afni,peakmasks).each do |d|
  %w(difference).each do |m|
    directory File.join(d,m)
    directory File.join(d,m,'cv')
    dir_list.push(File.join(d,m))
    dir_list.push(File.join(d,m,'cv'))
  end
end
task :makedirs => dir_list

# MASKS AND REFERENCE ANATOMY
TT_N27 = "#{DATA_DIR}/../CommonBrains/TT_N27_funcres.nii"
MASK_ORIG = [
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
MASK_TLRC = [
  "#{DATA_DIR}/mask/handmade/funcres/mask01+tlrc.HEAD",
  "#{DATA_DIR}/mask/handmade/funcres/mask02+tlrc.HEAD",
  "#{DATA_DIR}/mask/handmade/funcres/mask03+tlrc.HEAD",
  "#{DATA_DIR}/mask/handmade/funcres/mask04+tlrc.HEAD",
  "#{DATA_DIR}/mask/handmade/funcres/mask05+tlrc.HEAD",
  "#{DATA_DIR}/mask/handmade/funcres/mask06+tlrc.HEAD",
  "#{DATA_DIR}/mask/handmade/funcres/mask07+tlrc.HEAD",
  "#{DATA_DIR}/mask/handmade/funcres/mask08+tlrc.HEAD",
  "#{DATA_DIR}/mask/handmade/funcres/mask09+tlrc.HEAD",
  "#{DATA_DIR}/mask/handmade/funcres/mask10+tlrc.HEAD"
]
SUBJ_TLRC_REF = [
  "#{DATA_DIR}/T1/tlrc/01mnd_anat_train_al_ns+tlrc.HEAD",
  "#{DATA_DIR}/T1/tlrc/02mnd_anat_train_al_ns+tlrc.HEAD",
  "#{DATA_DIR}/T1/tlrc/03mnd_anat_train_al_ns+tlrc.HEAD",
  "#{DATA_DIR}/T1/tlrc/04mnd_anat_train_al_ns+tlrc.HEAD",
  "#{DATA_DIR}/T1/tlrc/05mnd_anat_train_al_ns+tlrc.HEAD",
  "#{DATA_DIR}/T1/tlrc/06mnd_anat_train_al_ns+tlrc.HEAD",
  "#{DATA_DIR}/T1/tlrc/07mnd_anat_train_al_ns+tlrc.HEAD",
  "#{DATA_DIR}/T1/tlrc/08mnd_anat_train_al_ns+tlrc.HEAD",
  "#{DATA_DIR}/T1/tlrc/09mnd_anat_train_al_ns+tlrc.HEAD",
  "#{DATA_DIR}/T1/tlrc/10mnd_anat_train_al_ns+tlrc.HEAD"
]
SUBJ_TLRC_MANUAL_REF = [
  "#{DATA_DIR}/raw/01/T1/01mnd_anat_train_al+tlrc.HEAD",
  "#{DATA_DIR}/raw/02/T1/02mnd_anat_train_al+tlrc.HEAD",
  "#{DATA_DIR}/raw/03/T1/03mnd_anat_train_al+tlrc.HEAD",
  "#{DATA_DIR}/raw/04/T1/04mnd_anat_train_al+tlrc.HEAD",
  "#{DATA_DIR}/raw/05/T1/05mnd_anat_train_al+tlrc.HEAD",
  "#{DATA_DIR}/raw/06/T1/06mnd_anat_train_al+tlrc.HEAD",
  "#{DATA_DIR}/raw/07/T1/07mnd_anat_train_al+tlrc.HEAD",
  "#{DATA_DIR}/raw/08/T1/08mnd_anat_train_al+tlrc.HEAD",
  "#{DATA_DIR}/raw/09/T1/09mnd_anat_train_al+tlrc.HEAD",
  "#{DATA_DIR}/raw/10/T1/10mnd_anat_train_al+tlrc.HEAD"
]
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

# "RAW" DATA (BEGINNING OF PIPELINE)
# This will produce a nested "list of lists": a list with a slot for each
# category, each slot containing a list with a slot for each subject.
TEXT_DIFF_ORIG = SUBJECT_INDEX.product(CATEGORY_INDEX,RADII_INDEX).collect do |s,c,r|
  "txt/difference/#{s}_#{c}_#{r}.orig"
end

TEXT_DIFF_POINTS_TLRC = SUBJECT_INDEX.product(CATEGORY_INDEX,RADII_INDEX).collect do |s,c,r|
  "txt/difference/#{s}_#{c}_#{r}.tlrc"
end

# Loops over the "outer" list (slot for each category), converts each list of
# subject-files to a FileList object, and perform a pathmap operation of the
# file names. This is done for each category, and the resulting 3 FileList
# objects are slotted into a new 3-element list "outer" list.
AFNI_DIFF_ORIG = TEXT_DIFF_ORIG.collect do |c|
  Rake::FileList.new(c).pathmap("afni/difference/%n+orig.HEAD").first
end
AFNI_DIFF_TLRC = TEXT_DIFF_ORIG.collect do |c|
  Rake::FileList.new(c).pathmap("afni/difference/%n+tlrc.HEAD").first
end
AFNI_DIFF_POINTS_TLRC = TEXT_DIFF_POINTS_TLRC.collect do |c|
  Rake::FileList.new(c).pathmap("afni/difference/%n_points+tlrc.HEAD")
end

TEXT_DIFF_ORIG_BY_CATEGORY_RADII = CATEGORY_INDEX.product(RADII_INDEX).collect do |c,r|
  TEXT_DIFF_ORIG.grep(/[0-9]+_#{c}_#{r}/)
end
AFNI_DIFF_ORIG_BY_CATEGORY_RADII = CATEGORY_INDEX.product(RADII_INDEX).collect do |c,r|
  AFNI_DIFF_ORIG.grep(/[0-9]+_#{c}_#{r}/)
end
AFNI_DIFF_TLRC_BY_CATEGORY_RADII = CATEGORY_INDEX.product(RADII_INDEX).collect do |c,r|
  AFNI_DIFF_TLRC.grep(/[0-9]+_#{c}_#{r}/)
end
TEXT_DIFF_POINTS_TLRC_BY_CATEGORY_RADII = CATEGORY_INDEX.product(RADII_INDEX).collect do |c,r|
  TEXT_DIFF_POINTS_TLRC.grep(/[0-9]+_#{c}_#{r}/)
end
AFNI_DIFF_POINTS_TLRC_BY_CATEGORY_RADII = CATEGORY_INDEX.product(RADII_INDEX).collect do |c,r|
  AFNI_DIFF_POINTS_TLRC.grep(/[0-9]+_#{c}_#{r}/)
end

# DERIVATIVE FILES
# N.B. the {} can be used to define a block, and allows the following to be
# expressed as a single line.
#   RANK_DIFF_ORIG = AFNI_DIFF_ORIG.collect do |c|
#     c.pathmap("rank/beta/%f")
#   end
# (to be clear, the following line is semantically the same as the previous 3 lines)
# RANK_DIFF_ORIG = AFNI_DIFF_ORIG.collect {|c| c.pathmap("rank/beta/%f")}
MEAN_DIFF_TLRC = CATEGORY_INDEX.product(RADII_INDEX).collect do |c,r|
  "mean_diff_#{c}_#{r}.b#{BLURFWHM}+tlrc.HEAD"
end
MEAN_DIFF_POINTS_TLRC = CATEGORY_INDEX.product(RADII_INDEX).collect do |c,r|
  "mean_diff_#{c}_#{r}.b#{BLURFWHM}_points+tlrc.HEAD"
end
TTEST_DIFF_TLRC = CATEGORY_INDEX.product(RADII_INDEX).collect do |c,r|
  "ttest_diff_#{c}_#{r}.b#{BLURFWHM}+tlrc.HEAD"
end
TTEST_DIFF_POINTS_TLRC = CATEGORY_INDEX.product(RADII_INDEX).collect do |c,r|
  "ttest_diff_#{c}_#{r}.b#{BLURFWHM}_points+tlrc.HEAD"
end
TTEST_DIFF_MASK_TLRC = CATEGORY_INDEX.product(RADII_INDEX).collect do |c,r|
  "ttest_diff_#{c}_#{r}.b#{BLURFWHM}_#{THRESHOLD}+tlrc.HEAD"
end
TTEST_DIFF_MASK_POINTS_TLRC = CATEGORY_INDEX.product(RADII_INDEX).collect do |c,r|
  "ttest_diff_#{c}_#{r}.b#{BLURFWHM}_#{THRESHOLD}_points+tlrc.HEAD"
end
TTEST_DIFF_MASK_TLRC_DUMP = CATEGORY_INDEX.product(RADII_INDEX).collect do |c,r|
  "ttest_diff_#{c}_#{r}.b#{BLURFWHM}_#{THRESHOLD}+tlrc.txt"
end
TTEST_DIFF_MASK_POINTS_TLRC_DUMP = CATEGORY_INDEX.product(RADII_INDEX).collect do |c,r|
  "ttest_diff_#{c}_#{r}.b#{BLURFWHM}_#{THRESHOLD}_points+tlrc.txt"
end
TTEST_DIFF_MASK_ORIG = CATEGORY_INDEX.product(RADII_INDEX).collect do |c,r|
  SUBJECT_INDEX.collect {|s| "peakmasks/ttest_diff_#{s}_#{c}_#{r}.b#{BLURFWHM}_#{THRESHOLD}+orig.HEAD"}
end
TTEST_DIFF_MASK_POINTS_ORIG = CATEGORY_INDEX.product(RADII_INDEX).collect do |c,r|
  SUBJECT_INDEX.collect {|s| "peakmasks/ttest_diff_#{s}_#{c}_#{r}.b#{BLURFWHM}_#{THRESHOLD}_points+orig.HEAD"}
end
TTEST_DIFF_MASK_ORIG_DUMP = CATEGORY_INDEX.product(RADII_INDEX).collect do |c,r|
  SUBJECT_INDEX.collect {|s| "peakmasks/ttest_diff_#{s}_#{c}_#{r}.b#{BLURFWHM}_#{THRESHOLD}+orig.txt"}
end
TTEST_DIFF_MASK_POINTS_ORIG_DUMP = CATEGORY_INDEX.product(RADII_INDEX).collect do |c,r|
  SUBJECT_INDEX.collect {|s| "peakmasks/ttest_diff_#{s}_#{c}_#{r}.b#{BLURFWHM}_#{THRESHOLD}_points+orig.txt"}
end

# FIGURE FILES
# ============
PNG_MEAN_DIFF_TLRC = CATEGORY_INDEX.product(RADII_INDEX).collect do |c,r|
  "mean_diff_#{c}_#{r}.b#{BLURFWHM}_#{THRESHOLD}.png"
end

PNG_MEAN_DIFF_POINTS_TLRC = CATEGORY_INDEX.product(RADII_INDEX).collect do |c,r|
  "mean_diff_#{c}_#{r}.b#{BLURFWHM}_#{THRESHOLD}_points.png"
end

PNG_TTEST_DIFF_TLRC = CATEGORY_INDEX.product(RADII_INDEX).collect do |c,r|
  "ttest_diff_#{c}_#{r}.b#{BLURFWHM}_#{THRESHOLD}.png"
end

PNG_TTEST_DIFF_POINTS_TLRC = CATEGORY_INDEX.product(RADII_INDEX).collect do |c,r|
  "ttest_diff_#{c}_#{r}.b#{BLURFWHM}_#{THRESHOLD}_points.png"
end

# AFNI TASKS
# ==========
namespace :afni do
  desc 'Launch AFNI and SUMA'
  task :start do
    afni_start(SURFACE_VOLUME,SPEC_BOTH)
  end

  desc 'Close AFNI and SUMA'
  task :stop do
    afni_stop()
  end
end

# FIGURE TASKS
# ============
png_mean = [
  PNG_MEAN_DIFF_TLRC,
  PNG_MEAN_DIFF_POINTS_TLRC
]
afni_mean = [
  MEAN_DIFF_TLRC,
  MEAN_DIFF_POINTS_TLRC
]
png_mean.zip(afni_mean).each do |png_list, afni_list|
  png_list.zip(afni_list).each do |target,source|
    file target => source do
      png_threshold(target, source, 0 , 0, '-', 'Reds_and_Blues')
    end
    CLEAN.push(target)
    CLEAN.push(target.sub('.png','.ppm'))
  end
end

png_ttest = [
  PNG_TTEST_DIFF_TLRC,
  PNG_TTEST_DIFF_POINTS_TLRC
]
afni_ttest = [
  TTEST_DIFF_MASK_TLRC,
  TTEST_DIFF_MASK_POINTS_TLRC
]
png_ttest.zip(afni_ttest).each do |png_list, afni_list|
  png_list.zip(afni_list).each do |target,source|
    file target => source do
#      png_ttest(target, source, 0, THRESHOLD, '+', 'Spectrum:yellow_to_red')
      png_ttest(target, source, 0, 0, '+', 'Spectrum:yellow_to_red')
    end
    CLEAN.push(target)
    CLEAN.push(target.sub('.png','.ppm'))
  end
end

# BUILD TASKS
# ===========
afni_orig = [
  AFNI_DIFF_ORIG_BY_CATEGORY_RADII
]
txt_orig = [
  TEXT_DIFF_ORIG_BY_CATEGORY_RADII
]
afni_orig.zip(txt_orig).each do |afni_lol,txt_lol|
  afni_lol.zip(txt_lol).each do |afni_list,txt_list|
    afni_list.zip(txt_list,MASK_ORIG).each do |target,source,anat|
      file target => [source,anat] do
        afni_undump(target,source,anat,XYZ_ORIENT)
      end
      CLOBBER.push(target)
      CLOBBER.push(target.sub(".HEAD",".BRIK"))
      CLOBBER.push(target.sub(".HEAD",".BRIK.gz"))
    end
  end
end

afni_orig = [
  AFNI_DIFF_POINTS_TLRC_BY_CATEGORY_RADII
]
txt_orig = [
  TEXT_DIFF_POINTS_TLRC_BY_CATEGORY_RADII
]
afni_orig.zip(txt_orig).each do |afni_lol,txt_lol|
  afni_lol.zip(txt_lol).each do |afni_list,txt_list|
    afni_list.zip(txt_list).each do |target,source|
      file target => [source,TT_N27] do
        afni_undump(target,source,TT_N27,XYZ_ORIENT)
      end
      CLOBBER.push(target)
      CLOBBER.push(target.sub(".HEAD",".BRIK"))
      CLOBBER.push(target.sub(".HEAD",".BRIK.gz"))
    end
  end
end

afni_orig = [
  AFNI_DIFF_ORIG_BY_CATEGORY_RADII
]
afni_tlrc = [
  AFNI_DIFF_TLRC_BY_CATEGORY_RADII
]
afni_tlrc.zip(afni_orig).each do |tlrc_lol,orig_lol|
  tlrc_lol.zip(orig_lol).each do |tlrc_list,orig_list|
    tlrc_list.zip(orig_list,WARP_REFERENCE).each do |target,source,anat|
      file target => [source,anat] do
        afni_adwarp(source, anat, VOXDIM)
      end
      CLOBBER.push(target)
      CLOBBER.push(target.sub('.HEAD','.BRIK'))
      CLOBBER.push(target.sub('.HEAD','.BRIK.gz'))
    end
  end
end

afni_tlrc = [
  AFNI_DIFF_TLRC_BY_CATEGORY_RADII,
  AFNI_DIFF_POINTS_TLRC_BY_CATEGORY_RADII
]
avg = [
  MEAN_DIFF_TLRC,
  MEAN_DIFF_POINTS_TLRC
]
avg.zip(afni_tlrc).each do |avg_list,tlrc_lol|
  avg_list.zip(tlrc_lol).each do |target,tlrc_list|
    file target => tlrc_list do
      afni_mean(target, tlrc_list, BLURFWHM)
    end
    CLEAN.push(target)
    CLEAN.push(target.sub('.HEAD','.BRIK'))
    CLEAN.push(target.sub('.HEAD','.BRIK.gz'))
  end
end

afni_tlrc = [
  AFNI_DIFF_TLRC_BY_CATEGORY_RADII,
  AFNI_DIFF_POINTS_TLRC_BY_CATEGORY_RADII
]
ttest = [
  TTEST_DIFF_TLRC,
  TTEST_DIFF_POINTS_TLRC
]
ttest.zip(afni_tlrc).each do |ttest_list,tlrc_lol|
  ttest_list.zip(tlrc_lol).each do |target, source_list|
    file target => source_list do
      afni_ttest(target, source_list, BLURFWHM)
    end
    CLOBBER.push(target)
    CLOBBER.push(target.sub(".HEAD",".BRIK"))
    CLOBBER.push(target.sub(".HEAD",".BRIK.gz"))
  end
end

ttest_mask = [
  TTEST_DIFF_MASK_TLRC,
  TTEST_DIFF_MASK_POINTS_TLRC
]
ttest = [
  TTEST_DIFF_TLRC,
  TTEST_DIFF_POINTS_TLRC
]
ttest_mask.zip(ttest).each do |mask_list,ttest_list|
  mask_list.zip(ttest_list).each do |target, source|
    file target => source do
      afni_statmask(target, source, THRESHOLD,'+')
    end
    CLOBBER.push(target)
    CLOBBER.push(target.sub(".HEAD",".BRIK"))
    CLOBBER.push(target.sub(".HEAD",".BRIK.gz"))
  end
end
ttest_mask = [
  TTEST_DIFF_MASK_TLRC,
  TTEST_DIFF_MASK_POINTS_TLRC
]
ttest_mask_dump = [
  TTEST_DIFF_MASK_TLRC_DUMP,
  TTEST_DIFF_MASK_POINTS_TLRC_DUMP
]
ttest_mask_dump.zip(ttest_mask).each do |dump_list,mask_list|
  dump_list.zip(mask_list).each do |target, source|
    file target => source do
      afni_maskdump(target, source, source)
    end
    CLOBBER.push(target)
    CLOBBER.push(target.sub(".HEAD",".BRIK"))
    CLOBBER.push(target.sub(".HEAD",".BRIK.gz"))
  end
end

ttest_mask_tlrc = [
  TTEST_DIFF_MASK_TLRC,
  TTEST_DIFF_MASK_POINTS_TLRC
]
ttest_mask_orig = [
  TTEST_DIFF_MASK_ORIG,
  TTEST_DIFF_MASK_POINTS_ORIG
]
full_list = []
ttest_mask_orig.zip(ttest_mask_tlrc).each do |orig_lol,tlrc_list|
  orig_lol.zip(tlrc_list).each do |orig_list, tlrc|
    orig_list.zip(WARP_REFERENCE,GRID_REFERENCE).each do |target,warp,grid|
      target_prefix = target.split('+').first
      # target_prefix = File.join(subject,File.basename(roi, "+tlrc.HEAD"))
      # target = File.join(subject,File.basename(roi))
      file target => [warp, grid, tlrc] do
        Dir.mktmpdir do |dir|
          binary_mask_tlrc = File.join(dir,'binary_mask+tlrc.HEAD')
          binary_mask_tlrc_prefix = binary_mask_tlrc.split('+').first
          inputs = "-a #{tlrc}"
          expr = 'step(a)'
          sh("3dcalc #{inputs} -expr '#{expr}' -prefix #{binary_mask_tlrc_prefix}")
          sh("3dfractionize -template #{grid} -input #{binary_mask_tlrc} -warp #{warp} -clip 0.2 -prefix #{target_prefix}")
        end
      end
      full_list.push(target)
      CLOBBER.push(target)
      CLOBBER.push(target.sub(".HEAD",".BRIK"))
      CLOBBER.push(target.sub(".HEAD",".BRIK.gz"))
    end
  end
end

ttest_mask_orig = [
  TTEST_DIFF_MASK_ORIG,
  TTEST_DIFF_MASK_POINTS_ORIG
]
ttest_mask_orig_dump = [
  TTEST_DIFF_MASK_ORIG_DUMP,
  TTEST_DIFF_MASK_POINTS_ORIG_DUMP
]
ttest_mask_orig_dump.zip(ttest_mask_orig).each do |dump_lol,mask_lol|
  dump_lol.zip(mask_lol).each do |dump_list,mask_list|
    dump_list.zip(mask_list).each do |target, source|
      file target => source do
        afni_maskdump(target, source, source)
      end
      CLOBBER.push(target)
      CLOBBER.push(target.sub(".HEAD",".BRIK"))
      CLOBBER.push(target.sub(".HEAD",".BRIK.gz"))
    end
  end
end

desc "Compose AFNI BRIK/HEAD pairs based on text files containing native coordinates."
task :afni => AFNI_DIFF_ORIG.flatten
desc "Warp AFNI native-space data to match TT_N27 template (based on existing warp data)."
task :tlrc => AFNI_DIFF_TLRC.flatten
desc "Compute voxelwise mean over subjects in TT_N27 space."
task :mean => MEAN_DIFF_TLRC.flatten
desc "Conduct voxelwise t-test over subjects in TT_N27 space."
task :ttest => TTEST_DIFF_TLRC.flatten
desc "Produce solution maps that include only voxels that exceed statistical threshold."
task :peaks => TTEST_DIFF_MASK_TLRC.flatten + TTEST_DIFF_MASK_TLRC_DUMP.flatten
desc "Warp peak maps into each subject's native space."
task :peaks_native => TTEST_DIFF_MASK_ORIG.flatten + TTEST_DIFF_MASK_ORIG_DUMP.flatten
desc "Produce figures of peak solution maps and raw average maps."
task :png => PNG_MEAN_DIFF_TLRC.flatten + PNG_TTEST_DIFF_TLRC.flatten
desc "Executes :afni,:tlrc,:mean,:ttest,:peaks,:png."
task :all => [:afni,:tlrc,:mean,:ttest,:peaks,:png]
desc "Same tasks, but based on text files that are already in common space."
namespace :points do
  task :afni => AFNI_DIFF_POINTS_TLRC.flatten
  task :mean => MEAN_DIFF_POINTS_TLRC.flatten
  task :ttest => TTEST_DIFF_POINTS_TLRC.flatten
  task :peaks => TTEST_DIFF_MASK_POINTS_TLRC.flatten + TTEST_DIFF_MASK_POINTS_TLRC_DUMP.flatten
  task :png => PNG_MEAN_DIFF_POINTS_TLRC.flatten + PNG_TTEST_DIFF_POINTS_TLRC.flatten
  task :all => [:afni,:mean,:ttest,:png]
end
