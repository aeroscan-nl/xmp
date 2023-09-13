require './spec/spec_helper.rb'

require 'exifr/jpeg'

describe "XMP with EXIFR::JPEG" do
  it "should parse image" do
    XMP::Silencer.silently { @img = EXIFR::JPEG.new('spec/fixtures/multiple-app1.jpg') }
    xmp = XMP.parse(@img)
    expect(xmp).to be_instance_of(XMP)
    expect(xmp.namespaces).to include(*%w{dc iX pdf photoshop rdf tiff x xap xapRights})
  end

  it "should parse dji mavic 3 jpg mode" do
    XMP::Silencer.silently { @img = EXIFR::JPEG.new('spec/fixtures/dji_mavic_jpg_mode.jpg') }
    xmp = XMP.parse(@img)
    expect(xmp).to be_instance_of(XMP)
    expect(xmp.namespaces).to include(*%w{GPano crs dc drone-dji exif rdf tiff x xmp xmpMM})
  end

  it "should parse dji mavic 3 image" do
    @img = EXIFR::JPEG.new('spec/fixtures/dji-mavic-3.jpg')
    xmp = XMP.parse(@img)
    expect(xmp).to be_instance_of(XMP)
    expect(xmp.namespaces).to include(*%w{GPano crs dc drone-dji exif rdf tiff x xmp xmpMM})
  end
end
