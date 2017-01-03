require 'rake'
require 'rake/clean'
require 'tmpdir'
require File.join(ENV['HOME'],'src','FacePlaceObject','rake','methods')

HOME = ENV['HOME']
XYZ_ORIENT = ENV.fetch('XYZ_ORIENT') {'RAI'} # order of xyz coordinates in txt files.
VOXDIM = ENV.fetch('VOXDIM') {3} # when applying a warp, this defines the voxelsize (in mm) for the warped data
_BLURFWHM = ENV.fetch('BLURFWHM') {4}
BLURFWHM = _BLURFWHM.to_i
DATADIR = ENV.fetch('DATADIR') {"#{HOME}/MRI/FacePlaceObject/data"}
PERMDIR = ENV.fetch('PERMDIR') {'../../permtest_stdevbias/solutionmaps'}
SHARED_ATLAS = ENV.fetch('SHARED_ATLAS') {"#{HOME}/MRI/Manchester/data/CommonBrains/MNI_EPI_funcRes.nii"}
SHARED_ATLAS_TLRC = ENV.fetch('SHARED_ATLAS_TLRC') {"#{HOME}/MRI/Manchester/data/CommonBrains/TT_N27_funcres.nii"}
SPEC_BOTH = "#{HOME}/suma_TT_N27/TT_N27_both.spec"
SURFACE_VOLUME = "./TT_N27_SurfVol.nii"

# INDEXES
PERMUTATION_INDEX = ('001'..'100').to_a
CATEGORY_INDEX = ['faces','places','objects']
SUBJECT_INDEX = ('01'..'10').to_a
CROSSVALIDATION_INDEX = ('01'..'10').to_a
#CVSUBSET = ENV.fetch('CVSUBSET').split {CROSSVALIDATION_INDEX}

dir_list = []
%w(afni zscore rank ranki).each do |d|
  %w(beta).each do |m|
    directory File.join(d,m)
    directory File.join(d,m,'cv')
    dir_list.push(File.join(d,m))
    dir_list.push(File.join(d,m,'cv'))
  end
end
task :makedirs => dir_list

# MASKS AND REFERENCE ANATOMY
MASK_ORIG = ["#{DATADIR}/mask/handmade/funcres/mask01+orig.HEAD",
               "#{DATADIR}/mask/handmade/funcres/mask02+orig.HEAD",
               "#{DATADIR}/mask/handmade/funcres/mask03+orig.HEAD",
               "#{DATADIR}/mask/handmade/funcres/mask04+orig.HEAD",
               "#{DATADIR}/mask/handmade/funcres/mask05+orig.HEAD",
               "#{DATADIR}/mask/handmade/funcres/mask06+orig.HEAD",
               "#{DATADIR}/mask/handmade/funcres/mask07+orig.HEAD",
               "#{DATADIR}/mask/handmade/funcres/mask08+orig.HEAD",
               "#{DATADIR}/mask/handmade/funcres/mask09+orig.HEAD",
               "#{DATADIR}/mask/handmade/funcres/mask10+orig.HEAD"
              ]
MASK_TLRC = ["#{DATADIR}/mask/handmade/funcres/mask01+tlrc.HEAD",
               "#{DATADIR}/mask/handmade/funcres/mask02+tlrc.HEAD",
               "#{DATADIR}/mask/handmade/funcres/mask03+tlrc.HEAD",
               "#{DATADIR}/mask/handmade/funcres/mask04+tlrc.HEAD",
               "#{DATADIR}/mask/handmade/funcres/mask05+tlrc.HEAD",
               "#{DATADIR}/mask/handmade/funcres/mask06+tlrc.HEAD",
               "#{DATADIR}/mask/handmade/funcres/mask07+tlrc.HEAD",
               "#{DATADIR}/mask/handmade/funcres/mask08+tlrc.HEAD",
               "#{DATADIR}/mask/handmade/funcres/mask09+tlrc.HEAD",
               "#{DATADIR}/mask/handmade/funcres/mask10+tlrc.HEAD"
              ]
SUBJ_TLRC_REF = ["#{DATADIR}/T1/tlrc/01mnd_anat_train_al_ns+tlrc.HEAD",
                 "#{DATADIR}/T1/tlrc/02mnd_anat_train_al_ns+tlrc.HEAD",
                 "#{DATADIR}/T1/tlrc/03mnd_anat_train_al_ns+tlrc.HEAD",
                 "#{DATADIR}/T1/tlrc/04mnd_anat_train_al_ns+tlrc.HEAD",
                 "#{DATADIR}/T1/tlrc/05mnd_anat_train_al_ns+tlrc.HEAD",
                 "#{DATADIR}/T1/tlrc/06mnd_anat_train_al_ns+tlrc.HEAD",
                 "#{DATADIR}/T1/tlrc/07mnd_anat_train_al_ns+tlrc.HEAD",
                 "#{DATADIR}/T1/tlrc/08mnd_anat_train_al_ns+tlrc.HEAD",
                 "#{DATADIR}/T1/tlrc/09mnd_anat_train_al_ns+tlrc.HEAD",
                 "#{DATADIR}/T1/tlrc/10mnd_anat_train_al_ns+tlrc.HEAD"
                ]

# "RAW" DATA (BEGINNING OF PIPELINE)
# This will produce a nested "list of lists": a list with a slot for each
# category, each slot containing a list with a slot for each subject.
TEXT_BETA_ORIG = CATEGORY_INDEX.collect do |c|
  SUBJECT_INDEX.collect do |s|
    "txt/beta/#{s}_#{c}.orig"
  end
end

# Loops over the "outer" list (slot for each category), converts each list of
# subject-files to a FileList object, and perform a pathmap operation of the
# file names. This is done for each category, and the resulting 3 FileList
# objects are slotted into a new 3-element list "outer" list.
AFNI_BETA_ORIG = TEXT_BETA_ORIG.collect do |c|
  Rake::FileList.new(c).pathmap("afni/beta/%n+orig.HEAD")
end
AFNI_BETA_TLRC = TEXT_BETA_ORIG.collect do |c|
  Rake::FileList.new(c).pathmap("afni/beta/%n+tlrc.HEAD")
end

# DERIVATIVE FILES
# N.B. the {} can be used to define a block, and allows the following to be
# expressed as a single line.
#   RANK_BETA_ORIG = AFNI_BETA_ORIG.collect do |c|
#     c.pathmap("rank/beta/%f")
#   end
# (to be clear, the following line is semantically the same as the previous 3 lines)
# RANK_BETA_ORIG = AFNI_BETA_ORIG.collect {|c| c.pathmap("rank/beta/%f")}
MEAN_BETA_TLRC = CATEGORY_INDEX.collect {|c| "mean_beta_#{c}.b#{BLURFWHM}+tlrc.HEAD"}
OVERLAP_TLRC = CATEGORY_INDEX.collect {|c| "overlap_#{c}.b#{BLURFWHM}+tlrc.HEAD"}

# FIGURE FILES
# ============
PNG_MEAN_BETA_TLRC = CATEGORY_INDEX.collect {|c| "mean_beta_#{c}.b#{BLURFWHM}.png"}
PNG_OVERLAP_TLRC = CATEGORY_INDEX.collect {|c| "overlap_#{c}.b#{BLURFWHM}.png"}

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
  PNG_MEAN_BETA_TLRC
]
afni_mean = [
  MEAN_BETA_TLRC
]
png_mean.zip(afni_mean).each do |png_list, afni_list|
  png_list.zip(afni_list).each do |target,source|
    file target => source do
      png_threshold(target, source, 0 , 0, '-', 'Reds_and_Blues')
    end
    CLOBBER.push(target)
  end
end

png_overlap = [
  PNG_OVERLAP_TLRC
]
afni_overlap = [
  OVERLAP_TLRC
]
png_overlap.zip(afni_overlap).each do |png_list, afni_list|
  png_list.zip(afni_list).each do |target,source|
    file target => source do
      png_threshold(target, source, 0, SUBJECT_INDEX.length, '+', 'Spectrum:red_to_blue')
    end
    CLOBBER.push(target)
  end
end

# BUILD TASKS
# ===========
afni_orig = [
  AFNI_BETA_ORIG
]
txt_orig = [
  TEXT_BETA_ORIG
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
  AFNI_BETA_ORIG
]
afni_tlrc = [
  AFNI_BETA_TLRC
]
afni_tlrc.zip(afni_orig).each do |tlrc_lol,orig_lol|
  tlrc_lol.zip(orig_lol).each do |tlrc_list,orig_list|
    tlrc_list.zip(orig_list,SUBJ_TLRC_REF).each do |target,source,anat|
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
  AFNI_BETA_TLRC
]
avg = [
  MEAN_BETA_TLRC
]
avg.zip(afni_tlrc).each do |avg_list,tlrc_lol|
  avg_list.zip(tlrc_lol).each do |target,tlrc_list|
    file target => tlrc_list do
      afni_mean(target, tlrc_list, BLURFWHM)
    end
    CLOBBER.push(target)
    CLOBBER.push(target.sub('.HEAD','.BRIK'))
    CLOBBER.push(target.sub('.HEAD','.BRIK.gz'))
  end
end

afni_tlrc = [
  AFNI_BETA_TLRC
]
overlap = [
  OVERLAP_TLRC
]
overlap.zip(afni_tlrc).each do |overlap_list,tlrc_lol|
  overlap_list.zip(tlrc_lol).each do |target,tlrc_list|
    file target => tlrc_list do
      afni_overlap(target, tlrc_list, BLURFWHM)
    end
    CLOBBER.push(target)
    CLOBBER.push(target.sub('.HEAD','.BRIK'))
    CLOBBER.push(target.sub('.HEAD','.BRIK.gz'))
  end
end
