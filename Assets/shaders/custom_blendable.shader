HEADER
{
	DevShader = false;
	Description = "Custom Multiblend Shader";
	Version = 1;
}

//=========================================================================================================================

MODES
{
	Forward();
	Depth(); 
	ToolsWireframe( "vr_tools_wireframe.shader" );
	ToolsShadingComplexity( "tools_shading_complexity.shader");
}

//=========================================================================================================================

FEATURES
{
    #include "common/features.hlsl"
	Feature( F_MULTIBLEND, 0..3 ( 0="1 Layers", 1="2 Layers", 2="3 Layers", 3="4 Layers" ), "Number Of Blendable Layers" );
	Feature( F_USE_TINT_MASKS_IN_VERTEX_PAINT, 0..1, "Use Tint Masks In Vertex Paint" );

}

COMMON
{
	#include "common/shared.hlsl"
	#include "procedural.hlsl"

	#define S_UV2 1
	#define CUSTOM_MATERIAL_INPUTS
}

struct VertexInput
{	
	float4 vColorBlendValues : TEXCOORD4 < Semantic( VertexPaintBlendParams ); >;
	float4 vColorPaintValues : TEXCOORD5 < Semantic( VertexPaintTintColor ); >;
	float4 vColor : COLOR0 < Semantic( Color ); >;
	#include "common/vertexinput.hlsl"
};

struct PixelInput
{
	float4 vColor : COLOR0;
	float4 vBlendValues		 : TEXCOORD14;
	float4 vPaintValues		 : TEXCOORD15;
	#include "common/pixelinput.hlsl"
};

VS
{

	
	StaticCombo( S_MULTIBLEND, F_MULTIBLEND, Sys( PC ) );
	#include "common/vertex.hlsl"
	BoolAttribute( VertexPaintUI2Layer, F_MULTIBLEND == 1 );
	BoolAttribute( VertexPaintUI3Layer, F_MULTIBLEND == 2 );
	BoolAttribute( VertexPaintUI4Layer, F_MULTIBLEND == 3 );
	BoolAttribute( VertexPaintUI5Layer, F_MULTIBLEND == 4 );


	BoolAttribute( VertexPaintUIPickColor, true );
	BoolAttribute( ShadowFastPath, true );

	//
	// Main
	//
	// PS_INPUT MainVs( VS_INPUT i )
	// {
	// 	PS_INPUT o = ProcessVertex( i );

	// 	o.vBlendValues = i.vColorBlendValues;
    //     o.vPaintValues = i.vColorPaintValues;

	// 	// Models don't have vertex paint data, let's avoid painting them black


	// 	return FinalizeVertex( o );
	// }
	PixelInput MainVs( VertexInput v )
	{
		PixelInput i = ProcessVertex( v );
		i.vBlendValues = v.vColorBlendValues;
		i.vPaintValues = v.vColorPaintValues;
		return FinalizeVertex( i );
	}
}

PS
{

	StaticCombo( S_MULTIBLEND, F_MULTIBLEND, Sys( PC ) );
	#include "common/pixel.hlsl"
	
	SamplerState g_sSampler0 < Filter( ANISO ); AddressU( WRAP ); AddressV( WRAP ); >;
	CreateInputTexture2D( SurfacesAlbedoBase, Srgb, 8, "None", "_color", "Base Layer,1/Surfaces Settings,1/38", Default4( 0.75, 0.75, 0.75, 1.00 ) );
	CreateInputTexture2D( SurfacesTintMaskBase, Linear, 8, "None", "_mask", "Base Layer,1/Surfaces Settings,1/42", Default4( 1.00, 1.00, 1.00, 1.00 ) );
	CreateInputTexture2D( SurfacesAlbedoA, Srgb, 8, "None", "_color", "Red Layer,2/Surfaces Settings,1/38", Default4( 0.75, 0.75, 0.75, 1.00 ) );
	CreateInputTexture2D( SurfacesTintMaskA, Linear, 8, "None", "_mask", "Red Layer,2/Surfaces Settings,1/42", Default4( 1.00, 1.00, 1.00, 1.00 ) );
	CreateInputTexture2D( SurfacesBlendA, Linear, 8, "None", "_mask", "Red Layer,2/Surfaces Settings,1/61", Default4( 0.50, 0.50, 0.50, 1.00 ) );
	CreateInputTexture2D( SurfacesAlbedoB, Srgb, 8, "None", "_color", "Green Layer,3/Surfaces Settings,1/38", Default4( 0.75, 0.75, 0.75, 1.00 ) );
	CreateInputTexture2D( SurfacesTintMaskB, Linear, 8, "None", "_mask", "Green Layer,3/Surfaces Settings,1/42", Default4( 1.00, 1.00, 1.00, 1.00 ) );
	CreateInputTexture2D( SurfacesBlendB, Linear, 8, "None", "_mask", "Green Layer,3/Surfaces Settings,1/61", Default4( 0.50, 0.50, 0.50, 1.00 ) );
	CreateInputTexture2D( SurfacesCracksBase, Linear, 8, "None", "_mask", "Base Layer,1/Surfaces Settings,1/63", Default4( 0.00, 0.00, 0.00, 1.00 ) );
	CreateInputTexture2D( SurfacesAmbientOcclusionBase, Linear, 8, "None", "_ao", "Base Layer,1/Surfaces Settings,1/60", Default4( 1.00, 1.00, 1.00, 1.00 ) );
	CreateInputTexture2D( SurfacesCracksA, Linear, 8, "None", "_mask", "Red Layer,2/Surfaces Settings,1/63", Default4( 0.00, 0.00, 0.00, 1.00 ) );
	CreateInputTexture2D( SurfacesAmbientOcclusionA, Linear, 8, "None", "_ao", "Red Layer,2/Surfaces Settings,1/60", Default4( 1.00, 1.00, 1.00, 1.00 ) );
	CreateInputTexture2D( SurfacesCracksB, Linear, 8, "None", "_mask", "Green Layer,3/Surfaces Settings,1/63", Default4( 0.00, 0.00, 0.00, 1.00 ) );
	CreateInputTexture2D( SurfacesAmbientOcclusionB, Linear, 8, "None", "_ao", "Green Layer,3/Surfaces Settings,1/60", Default4( 1.00, 1.00, 1.00, 1.00 ) );
	CreateInputTexture2D( SurfacesBlendBase, Linear, 8, "None", "_mask", "Base Layer,1/Surfaces Settings,1/61", Default4( 0.50, 0.50, 0.50, 1.00 ) );
	CreateInputTexture2D( SurfacesPorounesssBase, Linear, 8, "None", "_mask", "Base Layer,1/Surfaces Settings,1/66", Default4( 1.00, 1.00, 1.00, 1.00 ) );
	CreateInputTexture2D( SurfacesMetalnessBase, Linear, 8, "None", "_metal", "Base Layer,1/Surfaces Settings,1/59", Default4( 0.00, 0.00, 0.00, 1.00 ) );
	CreateInputTexture2D( SurfacesPorounesssA, Linear, 8, "None", "_mask", "Red Layer,2/Surfaces Settings,1/66", Default4( 1.00, 1.00, 1.00, 1.00 ) );
	CreateInputTexture2D( SurfacesMetalnessA, Linear, 8, "None", "_metal", "Red Layer,2/Surfaces Settings,1/59", Default4( 0.00, 0.00, 0.00, 1.00 ) );
	CreateInputTexture2D( SurfacesPorounesssB, Linear, 8, "None", "_mask", "Green Layer,3/Surfaces Settings,1/66", Default4( 1.00, 1.00, 1.00, 1.00 ) );
	CreateInputTexture2D( SurfacesMetalnessB, Linear, 8, "None", "_metal", "Green Layer,3/Surfaces Settings,1/59", Default4( 0.00, 0.00, 0.00, 1.00 ) );
	CreateInputTexture2D( RainRipplesNormalOpacityTemporalA, Linear, 8, "None", "_color", "Weather Layer,4/Rain Settings,5/15", DefaultFile( "textures/rain_ripples.png" ) );
	CreateInputTexture2D( RainRipplesNormalOpacityTemporalB, Linear, 8, "None", "_color", "Weather Layer,4/Rain Settings,5/22", DefaultFile( "textures/rain_ripples.png" ) );
	CreateInputTexture2D( RainRipplesNormalOpacityTemporalC, Linear, 8, "None", "_color", "Weather Layer,4/Rain Settings,5/29", DefaultFile( "textures/rain_ripples.png" ) );
	CreateInputTexture2D( RainRipplesNormalOpacityTemporalD, Linear, 8, "None", "_color", "Weather Layer,4/Rain Settings,5/37", DefaultFile( "textures/rain_ripples.png" ) );
	CreateInputTexture2D( WaterCausticsAlphaA, Srgb, 8, "None", "_color", "Weather Layer,4/Caustics Settings,4/3", DefaultFile( "textures/caustics_1.png" ) );
	CreateInputTexture2D( WaterRipplesNormalA, Linear, 8, "None", "_color", "Weather Layer,4/Ripples Settings,3/1", DefaultFile( "textures/water_ripples_1.png" ) );
	CreateInputTexture2D( WaterCausticsAlphaB, Srgb, 8, "None", "_color", "Weather Layer,4/Caustics Settings,4/8", DefaultFile( "textures/caustics_2.png" ) );
	CreateInputTexture2D( WaterRipplesNormalB, Linear, 8, "None", "_color", "Weather Layer,4/Ripples Settings,3/6", DefaultFile( "textures/water_ripples_2.png" ) );
	CreateInputTexture2D( SurfacesEmissionMaskBase, Linear, 8, "None", "_mask", "Base Layer,1/Surfaces Settings,1/52", Default4( 0.00, 0.00, 0.00, 1.00 ) );
	CreateInputTexture2D( SurfacesEmissionMaskA, Linear, 8, "None", "_mask", "Red Layer,2/Surfaces Settings,1/52", Default4( 0.00, 0.00, 0.00, 1.00 ) );
	CreateInputTexture2D( SurfacesEmissionMaskB, Linear, 8, "None", "_mask", "Green Layer,3/Surfaces Settings,1/52", Default4( 0.00, 0.00, 0.00, 1.00 ) );
	CreateInputTexture2D( SurfacesNormalBase, Linear, 8, "None", "_normal", "Base Layer,1/Surfaces Settings,1/56", Default4( 0.50, 0.50, 1.00, 1.00 ) );
	CreateInputTexture2D( SurfacesNormalA, Linear, 8, "None", "_normal", "Red Layer,2/Surfaces Settings,1/56", Default4( 0.50, 0.50, 1.00, 1.00 ) );
	CreateInputTexture2D( SurfacesNormalB, Linear, 8, "None", "_normal", "Green Layer,3/Surfaces Settings,1/56", Default4( 0.50, 0.50, 1.00, 1.00 ) );
	CreateInputTexture2D( SurfacesRoughnessBase, Linear, 8, "None", "_rough", "Base Layer,1/Surfaces Settings,1/58", Default4( 0.50, 0.50, 0.50, 1.00 ) );
	CreateInputTexture2D( SurfacesRoughnessA, Linear, 8, "None", "_rough", "Red Layer,2/Surfaces Settings,1/58", Default4( 0.50, 0.50, 0.50, 1.00 ) );
	CreateInputTexture2D( SurfacesRoughnessB, Linear, 8, "None", "_rough", "Green Layer,3/Surfaces Settings,1/58", Default4( 0.50, 0.50, 0.50, 1.00 ) );
	Texture2D g_tSurfacesAlbedoBase < Channel( RGBA, Box( SurfacesAlbedoBase ), Srgb ); OutputFormat( DXT5 ); SrgbRead( True ); >;
	Texture2D g_tSurfacesTintMaskBase < Channel( RGBA, Box( SurfacesTintMaskBase ), Linear ); OutputFormat( DXT5 ); SrgbRead( False ); >;
	Texture2D g_tSurfacesAlbedoA < Channel( RGBA, Box( SurfacesAlbedoA ), Srgb ); OutputFormat( DXT5 ); SrgbRead( True ); >;
	Texture2D g_tSurfacesTintMaskA < Channel( RGBA, Box( SurfacesTintMaskA ), Linear ); OutputFormat( DXT5 ); SrgbRead( False ); >;
	Texture2D g_tSurfacesBlendA < Channel( RGBA, Box( SurfacesBlendA ), Linear ); OutputFormat( DXT5 ); SrgbRead( False ); >;
	Texture2D g_tSurfacesAlbedoB < Channel( RGBA, Box( SurfacesAlbedoB ), Srgb ); OutputFormat( DXT5 ); SrgbRead( True ); >;
	Texture2D g_tSurfacesTintMaskB < Channel( RGBA, Box( SurfacesTintMaskB ), Linear ); OutputFormat( DXT5 ); SrgbRead( False ); >;
	Texture2D g_tSurfacesBlendB < Channel( RGBA, Box( SurfacesBlendB ), Linear ); OutputFormat( DXT5 ); SrgbRead( False ); >;
	Texture2D g_tSurfacesCracksBase < Channel( RGBA, Box( SurfacesCracksBase ), Linear ); OutputFormat( DXT5 ); SrgbRead( False ); >;
	Texture2D g_tSurfacesAmbientOcclusionBase < Channel( RGBA, Box( SurfacesAmbientOcclusionBase ), Linear ); OutputFormat( DXT5 ); SrgbRead( False ); >;
	Texture2D g_tSurfacesCracksA < Channel( RGBA, Box( SurfacesCracksA ), Linear ); OutputFormat( DXT5 ); SrgbRead( False ); >;
	Texture2D g_tSurfacesAmbientOcclusionA < Channel( RGBA, Box( SurfacesAmbientOcclusionA ), Linear ); OutputFormat( DXT5 ); SrgbRead( False ); >;
	Texture2D g_tSurfacesCracksB < Channel( RGBA, Box( SurfacesCracksB ), Linear ); OutputFormat( DXT5 ); SrgbRead( False ); >;
	Texture2D g_tSurfacesAmbientOcclusionB < Channel( RGBA, Box( SurfacesAmbientOcclusionB ), Linear ); OutputFormat( DXT5 ); SrgbRead( False ); >;
	Texture2D g_tSurfacesBlendBase < Channel( RGBA, Box( SurfacesBlendBase ), Linear ); OutputFormat( DXT5 ); SrgbRead( False ); >;
	Texture2D g_tSurfacesPorounesssBase < Channel( RGBA, Box( SurfacesPorounesssBase ), Linear ); OutputFormat( DXT5 ); SrgbRead( False ); >;
	Texture2D g_tSurfacesMetalnessBase < Channel( RGBA, Box( SurfacesMetalnessBase ), Linear ); OutputFormat( DXT5 ); SrgbRead( False ); >;
	Texture2D g_tSurfacesPorounesssA < Channel( RGBA, Box( SurfacesPorounesssA ), Linear ); OutputFormat( DXT5 ); SrgbRead( False ); >;
	Texture2D g_tSurfacesMetalnessA < Channel( RGBA, Box( SurfacesMetalnessA ), Linear ); OutputFormat( DXT5 ); SrgbRead( False ); >;
	Texture2D g_tSurfacesPorounesssB < Channel( RGBA, Box( SurfacesPorounesssB ), Linear ); OutputFormat( DXT5 ); SrgbRead( False ); >;
	Texture2D g_tSurfacesMetalnessB < Channel( RGBA, Box( SurfacesMetalnessB ), Linear ); OutputFormat( DXT5 ); SrgbRead( False ); >;
	Texture2D g_tRainRipplesNormalOpacityTemporalA < Channel( RGBA, Box( RainRipplesNormalOpacityTemporalA ), Linear ); OutputFormat( DXT5 ); SrgbRead( False ); >;
	Texture2D g_tRainRipplesNormalOpacityTemporalB < Channel( RGBA, Box( RainRipplesNormalOpacityTemporalB ), Linear ); OutputFormat( DXT5 ); SrgbRead( False ); >;
	Texture2D g_tRainRipplesNormalOpacityTemporalC < Channel( RGBA, Box( RainRipplesNormalOpacityTemporalC ), Linear ); OutputFormat( DXT5 ); SrgbRead( False ); >;
	Texture2D g_tRainRipplesNormalOpacityTemporalD < Channel( RGBA, Box( RainRipplesNormalOpacityTemporalD ), Linear ); OutputFormat( DXT5 ); SrgbRead( False ); >;
	Texture2D g_tWaterCausticsAlphaA < Channel( RGBA, Box( WaterCausticsAlphaA ), Srgb ); OutputFormat( DXT5 ); SrgbRead( True ); >;
	Texture2D g_tWaterRipplesNormalA < Channel( RGBA, Box( WaterRipplesNormalA ), Linear ); OutputFormat( DXT5 ); SrgbRead( False ); >;
	Texture2D g_tWaterCausticsAlphaB < Channel( RGBA, Box( WaterCausticsAlphaB ), Srgb ); OutputFormat( DXT5 ); SrgbRead( True ); >;
	Texture2D g_tWaterRipplesNormalB < Channel( RGBA, Box( WaterRipplesNormalB ), Linear ); OutputFormat( DXT5 ); SrgbRead( False ); >;
	Texture2D g_tSurfacesEmissionMaskBase < Channel( RGBA, Box( SurfacesEmissionMaskBase ), Linear ); OutputFormat( DXT5 ); SrgbRead( False ); >;
	Texture2D g_tSurfacesEmissionMaskA < Channel( RGBA, Box( SurfacesEmissionMaskA ), Linear ); OutputFormat( DXT5 ); SrgbRead( False ); >;
	Texture2D g_tSurfacesEmissionMaskB < Channel( RGBA, Box( SurfacesEmissionMaskB ), Linear ); OutputFormat( DXT5 ); SrgbRead( False ); >;
	Texture2D g_tSurfacesNormalBase < Channel( RGBA, Box( SurfacesNormalBase ), Linear ); OutputFormat( DXT5 ); SrgbRead( False ); >;
	Texture2D g_tSurfacesNormalA < Channel( RGBA, Box( SurfacesNormalA ), Linear ); OutputFormat( DXT5 ); SrgbRead( False ); >;
	Texture2D g_tSurfacesNormalB < Channel( RGBA, Box( SurfacesNormalB ), Linear ); OutputFormat( DXT5 ); SrgbRead( False ); >;
	Texture2D g_tSurfacesRoughnessBase < Channel( RGBA, Box( SurfacesRoughnessBase ), Linear ); OutputFormat( DXT5 ); SrgbRead( False ); >;
	Texture2D g_tSurfacesRoughnessA < Channel( RGBA, Box( SurfacesRoughnessA ), Linear ); OutputFormat( DXT5 ); SrgbRead( False ); >;
	Texture2D g_tSurfacesRoughnessB < Channel( RGBA, Box( SurfacesRoughnessB ), Linear ); OutputFormat( DXT5 ); SrgbRead( False ); >;
	TextureAttribute( LightSim_DiffuseAlbedoTexture, g_tWaterRipplesNormalB )
	TextureAttribute( RepresentativeTexture, g_tWaterRipplesNormalB )
	float g_flSurfacesAlbedoHueBase < UiType( Slider ); UiGroup( "Base Layer,1/Surfaces Settings,1/39" ); Default1( 0.5 ); Range1( 0, 1 ); >;
	float g_flSurfacesAlbedoSaturationBase < UiType( Slider ); UiGroup( "Base Layer,1/Surfaces Settings,1/40" ); Default1( 1 ); Range1( 0, 16 ); >;
	float g_flSurfacesAlbedoValueBase < UiType( Slider ); UiGroup( "Base Layer,1/Surfaces Settings,1/41" ); Default1( 1 ); Range1( 0, 16 ); >;
	float4 g_vSurfacesTintBase < UiType( Color ); UiGroup( "Base Layer,1/Surfaces Settings,1/43" ); Default4( 1.00, 1.00, 1.00, 1.00 ); >;
	float g_flSurfacesTintValueBase < UiType( Slider ); UiGroup( "Base Layer,1/Surfaces Settings,1/45" ); Default1( 1 ); Range1( 0, 1 ); >;
	float g_flSurfacesTintModeBase < UiType( Slider ); UiStep( 1 ); UiGroup( "Base Layer,1/Surfaces Settings,1/44" ); Default1( 3 ); Range1( 0, 20 ); >;
	float g_flSurfacesVertexTintValueBase < UiType( Slider ); UiGroup( "Base Layer,1/Surfaces Settings,1/48" ); Default1( 1 ); Range1( 0, 1 ); >;
	float g_flSurfacesVertexTintModeBase < UiType( Slider ); UiStep( 1 ); UiGroup( "Base Layer,1/Surfaces Settings,1/47" ); Default1( 3 ); Range1( 0, 20 ); >;
	float g_flUseTintMaskInVertexPaintBase < UiType( Slider ); UiGroup( "Base Layer,1/Surfaces Settings,1/46" ); Default1( 1 ); Range1( 0, 1 ); >;
	float g_flSurfacesAlbedoHueA < UiType( Slider ); UiGroup( "Red Layer,2/Surfaces Settings,1/39" ); Default1( 0.5 ); Range1( 0, 1 ); >;
	float g_flSurfacesAlbedoSaturationA < UiType( Slider ); UiGroup( "Red Layer,2/Surfaces Settings,1/40" ); Default1( 1 ); Range1( 0, 16 ); >;
	float g_flSurfacesAlbedoValueA < UiType( Slider ); UiGroup( "Red Layer,2/Surfaces Settings,1/41" ); Default1( 1 ); Range1( 0, 16 ); >;
	float4 g_vSurfacesTintA < UiType( Color ); UiGroup( "Red Layer,2/Surfaces Settings,1/43" ); Default4( 1.00, 1.00, 1.00, 1.00 ); >;
	float g_flSurfacesTintValueA < UiType( Slider ); UiGroup( "Red Layer,2/Surfaces Settings,1/45" ); Default1( 1 ); Range1( 0, 1 ); >;
	float g_flSurfacesTintModeA < UiType( Slider ); UiStep( 1 ); UiGroup( "Red Layer,2/Surfaces Settings,1/44" ); Default1( 3 ); Range1( 0, 20 ); >;
	float g_flSurfacesVertexTintValueA < UiType( Slider ); UiGroup( "Red Layer,2/Surfaces Settings,1/48" ); Default1( 1 ); Range1( 0, 1 ); >;
	float g_flSurfacesVertexTintModeA < UiType( Slider ); UiStep( 1 ); UiGroup( "Red Layer,2/Surfaces Settings,1/47" ); Default1( 3 ); Range1( 0, 20 ); >;
	float g_flUseTintMaskInVertexPaintA < UiType( Slider ); UiGroup( "Red Layer,2/Surfaces Settings,1/46" ); Default1( 1 ); Range1( 0, 1 ); >;
	float g_flUseModelsVertexColor < UiType( Slider ); UiStep( 1 ); UiGroup( "Material Settings,0/Textures Settings,0/0" ); Default1( 0 ); Range1( 0, 1 ); >;
	float g_flSurfacesBlendSoftnessA < UiType( Slider ); UiGroup( "Red Layer,2/Surfaces Settings,1/62" ); Default1( 0.1 ); Range1( 0.01, 1 ); >;
	float g_flSurfacesAlbedoHueB < UiType( Slider ); UiGroup( "Green Layer,3/Surfaces Settings,1/39" ); Default1( 0.5 ); Range1( 0, 1 ); >;
	float g_flSurfacesAlbedoSaturationB < UiType( Slider ); UiGroup( "Green Layer,3/Surfaces Settings,1/40" ); Default1( 1 ); Range1( 0, 16 ); >;
	float g_flSurfacesAlbedoValueB < UiType( Slider ); UiGroup( "Green Layer,3/Surfaces Settings,1/41" ); Default1( 1 ); Range1( 0, 16 ); >;
	float4 g_vSurfacesTintB < UiType( Color ); UiGroup( "Green Layer,3/Surfaces Settings,1/43" ); Default4( 1.00, 1.00, 1.00, 1.00 ); >;
	float g_flSurfacesTintValueB < UiType( Slider ); UiGroup( "Green Layer,3/Surfaces Settings,1/45" ); Default1( 1 ); Range1( 0, 1 ); >;
	float g_flSurfacesTintModeB < UiType( Slider ); UiStep( 1 ); UiGroup( "Green Layer,3/Surfaces Settings,1/44" ); Default1( 3 ); Range1( 0, 20 ); >;
	float g_flSurfacesVertexTintModeB < UiType( Slider ); UiStep( 1 ); UiGroup( "Green Layer,3/Surfaces Settings,1/47" ); Default1( 3 ); Range1( 0, 20 ); >;
	float g_flSurfacesVertexTintValueB < UiType( Slider ); UiGroup( "Green Layer,3/Surfaces Settings,1/48" ); Default1( 1 ); Range1( 0, 1 ); >;
	float g_flUseTintMaskInVertexPaintB < UiType( Slider ); UiGroup( "Green Layer,3/Surfaces Settings,1/46" ); Default1( 1 ); Range1( 0, 1 ); >;
	float g_flSurfacesBlendSoftnessB < UiType( Slider ); UiGroup( "Green Layer,3/Surfaces Settings,1/62" ); Default1( 0.1 ); Range1( 0.01, 1 ); >;
	float g_flSurfacesWetnessAlbedoHueBase < UiType( Slider ); UiGroup( "Base Layer,1/Wetness Settings,2/1" ); Default1( 0.5 ); Range1( 0, 1 ); >;
	float g_flSurfacesWetnessAlbedoSaturationBase < UiType( Slider ); UiGroup( "Base Layer,1/Wetness Settings,2/2" ); Default1( 1.5 ); Range1( 0, 16 ); >;
	float g_flSurfacesWetnessAlbedoValueBase < UiType( Slider ); UiGroup( "Base Layer,1/Wetness Settings,2/3" ); Default1( 0.5 ); Range1( 0, 16 ); >;
	float g_flSurfacesWetnessRoughnessValueBase < UiType( Slider ); UiGroup( "Base Layer,1/Wetness Settings,2/4" ); Default1( 0.1 ); Range1( 0, 1 ); >;
	float g_flSurfacesWetnessAlbedoHueA < UiType( Slider ); UiGroup( "Red Layer,2/Wetness Settings,2/1" ); Default1( 0.5 ); Range1( 0, 1 ); >;
	float g_flSurfacesWetnessAlbedoSaturationA < UiType( Slider ); UiGroup( "Red Layer,2/Wetness Settings,2/2" ); Default1( 1.5 ); Range1( 0, 16 ); >;
	float g_flSurfacesWetnessAlbedoValueA < UiType( Slider ); UiGroup( "Red Layer,2/Wetness Settings,2/3" ); Default1( 0.5 ); Range1( 0, 16 ); >;
	float g_flSurfacesWetnessRoughnessValueA < UiType( Slider ); UiGroup( "Red Layer,2/Wetness Settings,2/4" ); Default1( 0.1 ); Range1( 0, 1 ); >;
	float g_flSurfacesWetnessAlbedoHueB < UiType( Slider ); UiGroup( "Green Layer,3/Wetness Settings,2/1" ); Default1( 0.5 ); Range1( 0, 1 ); >;
	float g_flSurfacesWetnessAlbedoSaturationB < UiType( Slider ); UiGroup( "Green Layer,3/Wetness Settings,2/2" ); Default1( 1.5 ); Range1( 0, 16 ); >;
	float g_flSurfacesWetnessAlbedoValueB < UiType( Slider ); UiGroup( "Green Layer,3/Wetness Settings,2/3" ); Default1( 0.5 ); Range1( 0, 16 ); >;
	float g_flSurfacesWetnessRoughnessValueB < UiType( Slider ); UiGroup( "Green Layer,3/Wetness Settings,2/4" ); Default1( 0.1 ); Range1( 0, 1 ); >;
	float g_flSurfacesWetnessLayers < UiGroup( "Weather Layer,4/Weather Settings,1/2" ); Default1( 1 ); Range1( 0, 1 ); >;
	float g_flGenerateCracksFromInvertedAmbientOcclusionBase < UiType( Slider ); UiStep( 1 ); UiGroup( "Base Layer,1/Surfaces Settings,1/64" ); Default1( 1 ); Range1( 0, 1 ); >;
	float2 g_vSurfacesCracksLevelsBase < UiType( Slider ); UiGroup( "Base Layer,1/Surfaces Settings,1/65" ); Default2( 0.395,0.4 ); Range2( 0,0, 1,1 ); >;
	float g_flGenerateCracksFromInvertedAmbientOcclusionA < UiType( Slider ); UiStep( 1 ); UiGroup( "Red Layer,2/Surfaces Settings,1/64" ); Default1( 1 ); Range1( 0, 1 ); >;
	float2 g_vSurfacesCracksLevelsA < UiType( Slider ); UiGroup( "Red Layer,2/Surfaces Settings,1/65" ); Default2( 0.395,0.4 ); Range2( 0,0, 1,1 ); >;
	float g_flGenerateCracksFromInvertedAmbientOcclusionB < UiType( Slider ); UiStep( 1 ); UiGroup( "Green Layer,3/Surfaces Settings,1/64" ); Default1( 1 ); Range1( 0, 1 ); >;
	float2 g_vSurfacesCracksLevelsB < UiType( Slider ); UiGroup( "Green Layer,3/Surfaces Settings,1/65" ); Default2( 0.395,0.4 ); Range2( 0,0, 1,1 ); >;
	float g_flWaterPuddlesScale < UiGroup( "Weather Layer,4/Puddles Settings,2/4" ); Default1( 1 ); Range1( 0, 1 ); >;
	float g_flWaterPuddlesBlendSoftness < UiGroup( "Weather Layer,4/Puddles Settings,2/2" ); Default1( 0.4 ); Range1( 0, 1 ); >;
	float g_flWaterPuddlesAccumulation < UiGroup( "Weather Layer,4/Puddles Settings,2/1" ); Default1( 0.3 ); Range1( 0, 1 ); >;
	float g_flWaterPuddlesContrast < UiGroup( "Weather Layer,4/Puddles Settings,2/3" ); Default1( 0.05 ); Range1( 0, 1 ); >;
	float g_flGeneratePorousnessFromInvertedMetalnessBase < UiType( Slider ); UiStep( 1 ); UiGroup( "Base Layer,1/Surfaces Settings,1/67" ); Default1( 1 ); Range1( 0, 1 ); >;
	float g_flGeneratePorousnessFromInvertedMetalnessA < UiType( Slider ); UiStep( 1 ); UiGroup( "Red Layer,2/Surfaces Settings,1/67" ); Default1( 1 ); Range1( 0, 1 ); >;
	float g_flGeneratePorousnessFromInvertedMetalnessB < UiType( Slider ); UiStep( 1 ); UiGroup( "Green Layer,3/Surfaces Settings,1/67" ); Default1( 1 ); Range1( 0, 1 ); >;
	float4 g_vWaterPuddlesAlbedo < UiType( Color ); UiGroup( "Weather Layer,4/Puddles Settings,2/9" ); Default4( 1.00, 1.00, 1.00, 1.00 ); >;
	float g_flWaterPuddlesAlbedoHue < UiGroup( "Weather Layer,4/Puddles Settings,2/10" ); Default1( 0.5 ); Range1( 0, 1 ); >;
	float g_flWaterPuddlesAlbedoSaturation < UiGroup( "Weather Layer,4/Puddles Settings,2/11" ); Default1( 1.5 ); Range1( 0, 4 ); >;
	float g_flWaterPuddlesAlbedoValue < UiType( Slider ); UiGroup( "Weather Layer,4/Puddles Settings,2/12" ); Default1( 0.5 ); Range1( 0, 1 ); >;
	float g_flWaterPuddlesAlbedoBlendValue < UiType( Slider ); UiGroup( "Weather Layer,4/Puddles Settings,2/14" ); Default1( 1 ); Range1( 0, 1 ); >;
	float g_flWaterPuddlesAlbedoBlendMode < UiType( Slider ); UiStep( 1 ); UiGroup( "Weather Layer,4/Puddles Settings,2/13" ); Default1( 3 ); Range1( 0, 20 ); >;
	float4 g_vRainRipplesAlbedo < UiType( Color ); UiGroup( "Weather Layer,4/Rain Settings,5/6" ); Default4( 1.00, 1.00, 1.00, 1.00 ); >;
	float g_flRainRipplesAlbedoHue < UiGroup( "Weather Layer,4/Rain Settings,5/7" ); Default1( 0.5 ); Range1( 0, 1 ); >;
	float g_flRainRipplesAlbedoSaturation < UiGroup( "Weather Layer,4/Rain Settings,5/8" ); Default1( 1.5 ); Range1( 0, 4 ); >;
	float g_flRainRipplesAlbedoValue < UiType( Slider ); UiGroup( "Weather Layer,4/Rain Settings,5/9" ); Default1( 0.5 ); Range1( 0, 1 ); >;
	float g_flRainRipplesAlbedoBlendValue < UiType( Slider ); UiGroup( "Weather Layer,4/Rain Settings,5/11" ); Default1( 1 ); Range1( 0, 1 ); >;
	float g_flRainRipplesAlbedoBlendMode < UiType( Slider ); UiStep( 1 ); UiGroup( "Weather Layer,4/Rain Settings,5/10" ); Default1( 3 ); Range1( 0, 20 ); >;
	float g_flRainRipplesIntensityBase < UiType( Slider ); UiGroup( "Base Layer,1/Rain Settings,3/1" ); Default1( 4 ); Range1( 0, 32 ); >;
	float g_flRainRipplesRingsBase < UiType( Slider ); UiStep( 1 ); UiGroup( "Base Layer,1/Rain Settings,3/2" ); Default1( 1 ); Range1( 1, 3 ); >;
	float g_flRainRipplesSizeBase < UiType( Slider ); UiGroup( "Base Layer,1/Rain Settings,3/3" ); Default1( 0.2 ); Range1( 0, 1 ); >;
	float g_flRainRipplesStaticBase < UiType( Slider ); UiGroup( "Base Layer,1/Rain Settings,3/4" ); Default1( 0.9 ); Range1( 0, 1 ); >;
	float g_flRainRipplesIntensityA < UiType( Slider ); UiGroup( "Red Layer,2/Rain Settings,3/1" ); Default1( 4 ); Range1( 0, 32 ); >;
	float g_flRainRipplesRingsA < UiType( Slider ); UiStep( 1 ); UiGroup( "Red Layer,2/Rain Settings,3/2" ); Default1( 1 ); Range1( 1, 3 ); >;
	float g_flRainRipplesSizeA < UiType( Slider ); UiGroup( "Red Layer,2/Rain Settings,3/3" ); Default1( 0.2 ); Range1( 0, 1 ); >;
	float g_flRainRipplesStaticA < UiType( Slider ); UiGroup( "Red Layer,2/Rain Settings,3/4" ); Default1( 0.9 ); Range1( 0, 1 ); >;
	float g_flRainRipplesIntensityB < UiType( Slider ); UiGroup( "Green Layer,3/Rain Settings,3/1" ); Default1( 4 ); Range1( 0, 32 ); >;
	float g_flRainRipplesRingsB < UiType( Slider ); UiStep( 1 ); UiGroup( "Green Layer,3/Rain Settings,3/2" ); Default1( 1 ); Range1( 1, 3 ); >;
	float g_flRainRipplesSizeB < UiType( Slider ); UiGroup( "Green Layer,3/Rain Settings,3/3" ); Default1( 0.2 ); Range1( 0, 1 ); >;
	float g_flRainRipplesStaticB < UiType( Slider ); UiGroup( "Green Layer,3/Rain Settings,3/4" ); Default1( 0.9 ); Range1( 0, 1 ); >;
	float g_flRainRipplesSize < UiType( Slider ); UiGroup( "Weather Layer,4/Rain Settings,5/4" ); Default1( 1 ); Range1( 0, 1 ); >;
	float g_flRainRipplesCutoff < UiType( Slider ); UiGroup( "Weather Layer,4/Rain Settings,5/1" ); Default1( 0.5 ); Range1( 0, 1 ); >;
	float g_flRainRipplesRotationA < UiType( Slider ); UiGroup( "Weather Layer,4/Rain Settings,5/17" ); Default1( 0 ); Range1( 0, 360 ); >;
	float g_flRainRipplesSpeedA < UiType( Slider ); UiGroup( "Weather Layer,4/Rain Settings,5/19" ); Default1( 0.07 ); Range1( 0, 1 ); >;
	float g_flRainRipplesStatic < UiType( Slider ); UiGroup( "Weather Layer,4/Rain Settings,5/5" ); Default1( 0 ); Range1( 0, 1 ); >;
	float g_flRainRipplesScaleA < UiType( Slider ); UiGroup( "Weather Layer,4/Rain Settings,5/18" ); Default1( 0.8 ); Range1( 0, 8 ); >;
	float2 g_vRainRipplesLocationA < UiType( Slider ); UiGroup( "Weather Layer,4/Rain Settings,5/16" ); Default2( 0,0 ); Range2( 0,0, 1,1 ); >;
	float g_flRainRipplesLifespanA < UiType( Slider ); UiGroup( "Weather Layer,4/Rain Settings,5/21" ); Default1( 1.6 ); Range1( 0, 8 ); >;
	float g_flRainRipplesDelayA < UiType( Slider ); UiGroup( "Weather Layer,4/Rain Settings,5/20" ); Default1( 0.2 ); Range1( 0, 1 ); >;
	float g_flRainRipplesRings < UiType( Slider ); UiStep( 1 ); UiGroup( "Weather Layer,4/Rain Settings,5/3" ); Default1( 3 ); Range1( 1, 3 ); >;
	float g_flRainRipplesLevel < UiType( Slider ); UiStep( 1 ); UiGroup( "Weather Layer,4/Weather Settings,1/3" ); Default1( 4 ); Range1( 0, 4 ); >;
	float g_flRainRipplesRotationB < UiType( Slider ); UiGroup( "Weather Layer,4/Rain Settings,5/24" ); Default1( 0 ); Range1( 0, 360 ); >;
	float g_flRainRipplesSpeedB < UiType( Slider ); UiGroup( "Weather Layer,4/Rain Settings,5/26" ); Default1( 0.08 ); Range1( 0, 1 ); >;
	float g_flRainRipplesScaleB < UiType( Slider ); UiGroup( "Weather Layer,4/Rain Settings,5/25" ); Default1( 0.9 ); Range1( 0, 8 ); >;
	float2 g_vRainRipplesLocationB < UiType( Slider ); UiGroup( "Weather Layer,4/Rain Settings,5/23" ); Default2( 0.333,0.666 ); Range2( 0,0, 1,1 ); >;
	float g_flRainRipplesLifespanB < UiType( Slider ); UiGroup( "Weather Layer,4/Rain Settings,5/28" ); Default1( 1.7 ); Range1( 0, 9 ); >;
	float g_flRainRipplesDelayB < UiType( Slider ); UiGroup( "Weather Layer,4/Rain Settings,5/27" ); Default1( 0.17 ); Range1( 0, 1 ); >;
	float g_flRainRipplesRotationC < UiType( Slider ); UiGroup( "Weather Layer,4/Rain Settings,5/31" ); Default1( 0 ); Range1( 0, 360 ); >;
	float g_flRainRipplesSpeedC < UiType( Slider ); UiGroup( "Weather Layer,4/Rain Settings,5/33" ); Default1( 0 ); Range1( 0, 1 ); >;
	float g_flRainRipplesScaleC < UiType( Slider ); UiGroup( "Weather Layer,4/Rain Settings,5/32" ); Default1( 1.1 ); Range1( 0, 8 ); >;
	float2 g_vRainRipplesLocationC < UiType( Slider ); UiGroup( "Weather Layer,4/Rain Settings,5/30" ); Default2( 0.5,0.5 ); Range2( 0,0, 1,1 ); >;
	float g_flRainRipplesLifespanC < UiType( Slider ); UiGroup( "Weather Layer,4/Rain Settings,5/35" ); Default1( 1.8 ); Range1( 0, 8 ); >;
	float g_flRainRipplesDelayC < UiType( Slider ); UiGroup( "Weather Layer,4/Rain Settings,5/34" ); Default1( 0.19 ); Range1( 0, 1 ); >;
	float g_flRainRipplesRotationD < UiType( Slider ); UiGroup( "Weather Layer,4/Rain Settings,5/38" ); Default1( 5 ); Range1( 0, 360 ); >;
	float g_flRainRipplesSpeedD < UiType( Slider ); UiGroup( "Weather Layer,4/Rain Settings,5/40" ); Default1( 0.1 ); Range1( 0, 1 ); >;
	float g_flRainRipplesScaleD < UiType( Slider ); UiGroup( "Weather Layer,4/Rain Settings,5/39" ); Default1( 1 ); Range1( 0, 8 ); >;
	float2 g_vRainRipplesLocationD < UiType( Slider ); UiGroup( "Weather Layer,4/Rain Settings,5/37" ); Default2( 0.25,0.75 ); Range2( 0,0, 1,1 ); >;
	float g_flRainRipplesLifespanD < UiType( Slider ); UiGroup( "Weather Layer,4/Rain Settings,5/42" ); Default1( 1.84 ); Range1( 0, 8 ); >;
	float g_flRainRipplesDelayD < UiType( Slider ); UiGroup( "Weather Layer,4/Rain Settings,5/41" ); Default1( 0.18 ); Range1( 0, 1 ); >;
	float g_flWaterCausticsScaleA < UiType( Slider ); UiGroup( "Weather Layer,4/Caustics Settings,4/4" ); Default1( 2.5 ); Range1( 0, 16 ); >;
	float g_flWaterCausticsRotationA < UiType( Slider ); UiGroup( "Weather Layer,4/Caustics Settings,4/5" ); Default1( 0 ); Range1( 0, 360 ); >;
	float g_flWaterCausticsSpeedA < UiType( Slider ); UiGroup( "Weather Layer,4/Caustics Settings,4/6" ); Default1( 0.075 ); Range1( 0, 8 ); >;
	float g_flWaterCausticsNoiseDisplacementA < UiType( Slider ); UiGroup( "Weather Layer,4/Caustics Settings,4/7" ); Default1( 0.5 ); Range1( 0, 128 ); >;
	float g_flWaterRipplesScaleA < UiType( Slider ); UiGroup( "Weather Layer,4/Ripples Settings,3/2" ); Default1( 2 ); Range1( 0, 16 ); >;
	float g_flWaterRipplesRotationA < UiType( Slider ); UiGroup( "Weather Layer,4/Ripples Settings,3/3" ); Default1( 0 ); Range1( 0, 360 ); >;
	float g_flWaterRipplesSpeedA < UiType( Slider ); UiGroup( "Weather Layer,4/Ripples Settings,3/4" ); Default1( 0.15 ); Range1( 0, 8 ); >;
	float g_flWaterRipplesIntensityA < UiType( Slider ); UiGroup( "Weather Layer,4/Ripples Settings,3/5" ); Default1( 0.25 ); Range1( 0, 16 ); >;
	float g_flWaterCausticsNoiseDisplacementB < UiType( Slider ); UiGroup( "Weather Layer,4/Caustics Settings,4/12" ); Default1( 0.5 ); Range1( 0, 128 ); >;
	float g_flWaterRipplesScaleB < UiType( Slider ); UiGroup( "Weather Layer,4/Ripples Settings,3/7" ); Default1( 2 ); Range1( 0, 16 ); >;
	float g_flWaterRipplesRotationB < UiType( Slider ); UiGroup( "Weather Layer,4/Ripples Settings,3/8" ); Default1( 180 ); Range1( 0, 360 ); >;
	float g_flWaterRipplesSpeedB < UiType( Slider ); UiGroup( "Weather Layer,4/Ripples Settings,3/9" ); Default1( 0.15 ); Range1( 0, 8 ); >;
	float g_flWaterRipplesIntensityB < UiType( Slider ); UiGroup( "Weather Layer,4/Ripples Settings,3/10" ); Default1( 0.25 ); Range1( 0, 16 ); >;
	float g_flWaterCausticsScaleB < UiType( Slider ); UiGroup( "Weather Layer,4/Caustics Settings,4/9" ); Default1( 2.5 ); Range1( 0, 16 ); >;
	float g_flWaterCausticsRotationB < UiType( Slider ); UiGroup( "Weather Layer,4/Caustics Settings,4/10" ); Default1( 180 ); Range1( 0, 360 ); >;
	float g_flWaterCausticsSpeedB < UiType( Slider ); UiGroup( "Weather Layer,4/Caustics Settings,4/11" ); Default1( 0.075 ); Range1( 0, 18 ); >;
	float g_flWaterCausticsAlphaValue < UiType( Slider ); UiGroup( "Weather Layer,4/Caustics Settings,4/2" ); Default1( 0.75 ); Range1( 0, 32 ); >;
	float g_flWaterCausticsChromaticAberrationValue < UiType( Slider ); UiGroup( "Weather Layer,4/Caustics Settings,4/1" ); Default1( 2 ); Range1( 0, 64 ); >;
	float g_flWeatherBlendSoftness < UiGroup( "Weather Layer,4/Weather Settings,1/1" ); Default1( 0.1 ); Range1( 0, 1 ); >;
	float4 g_vSurfacesEmissionBase < UiType( Color ); UiGroup( "Base Layer,1/Surfaces Settings,1/53" ); Default4( 1.00, 1.00, 1.00, 1.00 ); >;
	float g_flSurfacesEmissionBrightnessBase < UiType( Slider ); UiGroup( "Base Layer,1/Surfaces Settings,1/54" ); Default1( 0 ); Range1( 0, 128 ); >;
	float4 g_vSurfacesEmissionA < UiType( Color ); UiGroup( "Red Layer,2/Surfaces Settings,1/53" ); Default4( 1.00, 1.00, 1.00, 1.00 ); >;
	float g_flSurfacesEmissionBrightnessA < UiType( Slider ); UiGroup( "Red Layer,2/Surfaces Settings,1/54" ); Default1( 0 ); Range1( 0, 128 ); >;
	float4 g_vSurfacesEmissionB < UiType( Color ); UiGroup( "Green Layer,3/Surfaces Settings,1/53" ); Default4( 1.00, 1.00, 1.00, 1.00 ); >;
	float g_flSurfacesEmissionBrightnessB < UiType( Slider ); UiGroup( "Green Layer,3/Surfaces Settings,1/54" ); Default1( 0 ); Range1( 0, 128 ); >;
	float4 g_vWaterPuddlesEmission < UiType( Color ); UiGroup( "Weather Layer,4/Puddles Settings,2/15" ); Default4( 1.00, 1.00, 1.00, 1.00 ); >;
	float g_flWaterPuddlesEmissionBrightness < UiGroup( "Weather Layer,4/Puddles Settings,2/16" ); Default1( 0 ); Range1( 0, 1 ); >;
	float g_flWaterPuddlesEmissionBlendValue < UiType( Slider ); UiGroup( "Weather Layer,4/Puddles Settings,2/18" ); Default1( 0 ); Range1( 0, 1 ); >;
	float g_flWaterPuddlesEmissionBlendMode < UiType( Slider ); UiStep( 1 ); UiGroup( "Weather Layer,4/Puddles Settings,2/17" ); Default1( 0 ); Range1( 0, 20 ); >;
	float g_flSurfacesNormalIntensityBase < UiType( Slider ); UiGroup( "Base Layer,1/Surfaces Settings,1/57" ); Default1( 1 ); Range1( 0, 1 ); >;
	float g_flSurfacesNormalIntensityA < UiType( Slider ); UiGroup( "Red Layer,2/Surfaces Settings,1/57" ); Default1( 1 ); Range1( 0, 1 ); >;
	float g_flSurfacesNormalIntensityB < UiType( Slider ); UiGroup( "Green Layer,3/Surfaces Settings,1/57" ); Default1( 1 ); Range1( 0, 1 ); >;
	float4 g_vWaterPuddlesNormal < UiType( Color ); UiGroup( "Weather Layer,4/Puddles Settings,2/22" ); Default4( 0.00, 0.00, 1.00, 1.00 ); >;
	float g_flWaterPuddlesNormalBlendValue < UiType( Slider ); UiGroup( "Weather Layer,4/Puddles Settings,2/24" ); Default1( 1 ); Range1( 0, 1 ); >;
	float g_flWaterPuddlesNormalBlendMode < UiType( Slider ); UiStep( 1 ); UiGroup( "Weather Layer,4/Puddles Settings,2/23" ); Default1( 1 ); Range1( 0, 3 ); >;
	float g_flRainRipplesIntensity < UiType( Slider ); UiGroup( "Weather Layer,4/Rain Settings,5/2" ); Default1( 0.5 ); Range1( 0, 16 ); >;
	float g_flWaterPuddlesRoughness < UiGroup( "Weather Layer,4/Puddles Settings,2/25" ); Default1( 0 ); Range1( 0, 1 ); >;
	float g_flWaterPuddlesRoughnessBlendValue < UiType( Slider ); UiGroup( "Weather Layer,4/Puddles Settings,2/27" ); Default1( 1 ); Range1( 0, 1 ); >;
	float g_flWaterPuddlesRoughnessBlendMode < UiType( Slider ); UiStep( 1 ); UiGroup( "Weather Layer,4/Puddles Settings,2/26" ); Default1( 1 ); Range1( 0, 20 ); >;
	float g_flRainRipplesRoughness < UiGroup( "Weather Layer,4/Rain Settings,5/12" ); Default1( 0 ); Range1( 0, 1 ); >;
	float g_flRainRipplesRoughnessBlendValue < UiType( Slider ); UiGroup( "Weather Layer,4/Rain Settings,5/14" ); Default1( 1 ); Range1( 0, 1 ); >;
	float g_flRainRipplesRoughnessBlendMode < UiType( Slider ); UiStep( 1 ); UiGroup( "Weather Layer,4/Rain Settings,5/13" ); Default1( 1 ); Range1( 0, 20 ); >;
	float g_flWaterPuddlesMetalness < UiGroup( "Weather Layer,4/Puddles Settings,2/28" ); Default1( 0 ); Range1( 0, 1 ); >;
	float g_flWaterPuddlesMetalnessBlendValue < UiType( Slider ); UiGroup( "Weather Layer,4/Puddles Settings,2/30" ); Default1( 0 ); Range1( 0, 1 ); >;
	float g_flWaterPuddlesMetalnessBlendMode < UiType( Slider ); UiStep( 1 ); UiGroup( "Weather Layer,4/Puddles Settings,2/29" ); Default1( 0 ); Range1( 0, 20 ); >;
	float g_flWaterPuddlesAmbientOcclusion < UiGroup( "Weather Layer,4/Puddles Settings,2/31" ); Default1( 0 ); Range1( 0, 1 ); >;
	float g_flWaterPuddlesAmbientOcclusionBlendValue < UiType( Slider ); UiGroup( "Weather Layer,4/Puddles Settings,2/33" ); Default1( 0 ); Range1( 0, 1 ); >;
	float g_flWaterPuddlesAmbientOcclusionBlendMode < UiType( Slider ); UiStep( 1 ); UiGroup( "Weather Layer,4/Puddles Settings,2/32" ); Default1( 0 ); Range1( 0, 20 ); >;
		
			float3 HueSaturationValue(float3 input, float hue, float saturation, float value )
			{
				float4 k = float4( 0.0, -1.0 / 3.0, 2.0 / 3.0, -1.0 );
				float4 p = lerp( float4( input.bg, k.wz ), float4( input.gb, k.xy ), step( input.b, input.g ) );
				float4 q = lerp( float4( p.xyw, input.r ), float4( input.r, p.yzx ), step( p.x, input.r ) );
				
				float d = q.x - min( q.w, q.y );
				float e = 1.0e-10;
				
				float3 hsv = float3( abs( q.z + ( q.w - q.y ) / ( 6.0 * d + e ) ), d / ( q.x + e ), q.x );
				
				float3 hsvOffset = float3(hsv.x + hue - 0.5, hsv.y * saturation, hsv.z * value);
				
				float4 m = float4( 1.0, 2.0 / 3.0, 1.0 / 3.0, 3.0 );
				return hsvOffset.z * lerp( m.xxx, saturate(abs( frac( hsvOffset.xxx + m.xyz ) * 6.0 - m.www ) - m.xxx), hsvOffset.y );
			}
			
	float Divide_blend( float a, float b )
	{
	    if( b > 0.0f )
	        return saturate( a / b );
	    else
	        return 0.0f;
	}
	
	float3 Divide_blend( float3 a, float3 b )
	{
	    return float3(
	        Divide_blend( a.r, b.r ),
	        Divide_blend( a.g, b.g ),
	        Divide_blend( a.b, b.b )
		);
	}
	
	float4 Divide_blend( float4 a, float4 b, bool blendAlpha = false )
	{
	    return float4(
	        Divide_blend( a.rgb, b.rgb ).rgb,
	        blendAlpha ? Divide_blend( a.a, b.a ) : max( a.a, b.a )
	    );
	}
	
	float HardMix_blend( float a, float b )
	{
	    if(a + b >= 1.0f) return 1.0f;
	    else return 0.0f;
	}
	
	float3 HardMix_blend( float3 a, float3 b )
	{
	    return float3(
	        HardMix_blend( a.r, b.r ),
	        HardMix_blend( a.g, b.g ),
	        HardMix_blend( a.b, b.b )
		);
	}
	
	float4 HardMix_blend( float4 a, float4 b, bool blendAlpha = false )
	{
	    return float4(
	        HardMix_blend( a.rgb, b.rgb ).rgb,
	        blendAlpha ? HardMix_blend( a.a, b.a ) : max( a.a, b.a )
	    );
	}
	
	float LinearLight_blend( float a, float b )
	{
	    if ( b <= 0.5f )
		{
			b *= 2.0f;
			return max( 0.0f, a + b - 1.0f );
		}
	    else
		{
			b = 2.0f * ( b - 0.5f );
			return min( 1.0f, a + b );
		}
	}
	
	float3 LinearLight_blend( float3 a, float3 b )
	{
	    return float3(
	        LinearLight_blend( a.r, b.r ),
	        LinearLight_blend( a.g, b.g ),
	        LinearLight_blend( a.b, b.b )
		);
	}
	
	float4 LinearLight_blend( float4 a, float4 b, bool blendAlpha = false )
	{
	    return float4(
	        LinearLight_blend( a.rgb, b.rgb ).rgb,
	        blendAlpha ? LinearLight_blend( a.a, b.a ) : max( a.a, b.a )
	    );
	}
	
	float VividLight_blend( float a, float b )
	{
	    if ( b <= 0.5f )
		{
			b *= 2.0f;
			if ( a >= 1.0f ) return 1.0f;
			if ( b <= 0.0f ) return 0.0f;
			return 1.0f - saturate( ( 1.0f - a ) / b );
		}
	    else
		{
			b = 2.0f * ( b - 0.5f );
			if ( a <= 0.0f ) return 0.0f;
			if ( b >= 1.0f ) return 1.0f;
			return saturate( a / ( 1.0f - b ) );
		}
	}
	
	float3 VividLight_blend( float3 a, float3 b )
	{
	    return float3(
	        VividLight_blend( a.r, b.r ),
	        VividLight_blend( a.g, b.g ),
	        VividLight_blend( a.b, b.b )
		);
	}
	
	float4 VividLight_blend( float4 a, float4 b, bool blendAlpha = false )
	{
	    return float4(
	        VividLight_blend( a.rgb, b.rgb ).rgb,
	        blendAlpha ? VividLight_blend( a.a, b.a ) : max( a.a, b.a )
	    );
	}
	
	float HardLight_blend( float a, float b )
	{
	    if(b <= 0.5f)
	        return 2.0f * a * b;
	    else
	        return 1.0f - 2.0f * (1.0f - a) * (1.0f - b);
	}
	
	float3 HardLight_blend( float3 a, float3 b )
	{
	    return float3(
	        HardLight_blend( a.r, b.r ),
	        HardLight_blend( a.g, b.g ),
	        HardLight_blend( a.b, b.b )
		);
	}
	
	float4 HardLight_blend( float4 a, float4 b, bool blendAlpha = false )
	{
	    return float4(
	        HardLight_blend( a.rgb, b.rgb ).rgb,
	        blendAlpha ? HardLight_blend( a.a, b.a ) : max( a.a, b.a )
	    );
	}
	
	float SoftLight_blend( float a, float b )
	{
	    if ( b <= 0.5f )
	        return 2.0f * a * b + a * a * ( 1.0f * 2.0f * b );
	    else 
	        return sqrt( a ) * ( 2.0f * b - 1.0f ) + 2.0f * a * (1.0f - b);
	}
	
	float3 SoftLight_blend( float3 a, float3 b )
	{
	    return float3(
	        SoftLight_blend( a.r, b.r ),
	        SoftLight_blend( a.g, b.g ),
	        SoftLight_blend( a.b, b.b )
		);
	}
	
	float4 SoftLight_blend( float4 a, float4 b, bool blendAlpha = false )
	{
	    return float4(
	        SoftLight_blend( a.rgb, b.rgb ).rgb,
	        blendAlpha ? SoftLight_blend( a.a, b.a ) : max( a.a, b.a )
	    );
	}
	
	float Overlay_blend( float a, float b )
	{
	    if ( a <= 0.5f )
	        return 2.0f * a * b;
	    else
	        return 1.0f - 2.0f * ( 1.0f - a ) * ( 1.0f - b );
	}
	
	float3 Overlay_blend( float3 a, float3 b )
	{
	    return float3(
	        Overlay_blend( a.r, b.r ),
	        Overlay_blend( a.g, b.g ),
	        Overlay_blend( a.b, b.b )
		);
	}
	
	float4 Overlay_blend( float4 a, float4 b, bool blendAlpha = false )
	{
	    return float4(
	        Overlay_blend( a.rgb, b.rgb ).rgb,
	        blendAlpha ? Overlay_blend( a.a, b.a ) : max( a.a, b.a )
	    );
	}
	
	float LinearDodge_blend( float a, float b )
	{
	    return min( 1.0f, a + b );
	}
	
	float3 LinearDodge_blend( float3 a, float3 b )
	{
	    return float3(
	        LinearDodge_blend( a.r, b.r ),
	        LinearDodge_blend( a.g, b.g ),
	        LinearDodge_blend( a.b, b.b )
		);
	}
	
	float4 LinearDodge_blend( float4 a, float4 b, bool blendAlpha = false )
	{
	    return float4(
	        LinearDodge_blend( a.rgb, b.rgb ).rgb,
	        blendAlpha ? LinearDodge_blend( a.a, b.a ) : max( a.a, b.a )
	    );
	}
	
	float ColorDodge_blend( float a, float b )
	{
	    if ( a <= 0.0f ) return 0.0f;
	    if ( b >= 1.0f ) return 1.0f;
	    return saturate( a / ( 1.0f - b ) );
	}
	
	float3 ColorDodge_blend( float3 a, float3 b )
	{
	    return float3(
	        ColorDodge_blend( a.r, b.r ),
	        ColorDodge_blend( a.g, b.g ),
	        ColorDodge_blend( a.b, b.b )
		);
	}
	
	float4 ColorDodge_blend( float4 a, float4 b, bool blendAlpha = false )
	{
	    return float4(
	        ColorDodge_blend( a.rgb, b.rgb ).rgb,
	        blendAlpha ? ColorDodge_blend( a.a, b.a ) : max( a.a, b.a )
	    );
	}
	
	float LinearBurn_blend( float a, float b )
	{
	    return max( 0.0f, a + b - 1.0f );
	}
	
	float3 LinearBurn_blend( float3 a, float3 b )
	{
	    return float3(
	        LinearBurn_blend( a.r, b.r ),
	        LinearBurn_blend( a.g, b.g ),
	        LinearBurn_blend( a.b, b.b )
		);
	}
	
	float4 LinearBurn_blend( float4 a, float4 b, bool blendAlpha = false )
	{
	    return float4(
	        LinearBurn_blend( a.rgb, b.rgb ).rgb,
	        blendAlpha ? LinearBurn_blend( a.a, b.a ) : max( a.a, b.a )
	    );
	}
	
	float ColorBurn_blend( float a, float b )
	{
	    if ( a >= 1.0f ) return 1.0f;
	    if ( b <= 0.0f ) return 0.0f;
	    return 1.0f - saturate( ( 1.0f - a ) / b );
	}
	
	float3 ColorBurn_blend( float3 a, float3 b )
	{
	    return float3(
	        ColorBurn_blend( a.r, b.r ),
	        ColorBurn_blend( a.g, b.g ),
	        ColorBurn_blend( a.b, b.b )
		);
	}
	
	float4 ColorBurn_blend( float4 a, float4 b, bool blendAlpha = false )
	{
	    return float4(
	        ColorBurn_blend( a.rgb, b.rgb ).rgb,
	        blendAlpha ? ColorBurn_blend( a.a, b.a ) : max( a.a, b.a )
	    );
	}
	
			float fBMNoise(float2 input, int octaves, float amplitude, float frequency, float value)
			{
				for(int i = 0; i < octaves; i++) 
				{
					value += amplitude * ValueNoise(frequency * input);
					amplitude *= 0.5;
					frequency *= 2.0;
				}
				return value;
			}
			
			float3 AxisDegrees( float3 input, float3 axis, float rotation )
			{
				rotation *= 3.1415926f/180.0f;
				float s = sin(rotation);
				float c = cos(rotation);
				float one_minus_c = 1.0 - c;
	
				axis = normalize(axis);
				float3x3 rot_mat = 
				{   one_minus_c * axis.x * axis.x + c, one_minus_c * axis.x * axis.y - axis.z * s, one_minus_c * axis.z * axis.x + axis.y * s,
					one_minus_c * axis.x * axis.y + axis.z * s, one_minus_c * axis.y * axis.y + c, one_minus_c * axis.y * axis.z - axis.x * s,
					one_minus_c * axis.z * axis.x - axis.y * s, one_minus_c * axis.y * axis.z + axis.x * s, one_minus_c * axis.z * axis.z + c
				};
				return float3(mul(rot_mat, input));
			}
			
			float Clamp( float input, float min, float max )
			{
				return clamp(input, min, max);
			}
								
			float3 Reoriented(float3 a, float3 b)
			{
				float3 t = a.xyz + float3(0.0, 0.0, 1.0);
				float3 u = b.xyz * float3(-1.0, -1.0, 1.0);
				return float3((t / t.z) * dot(t, u) - u);
			}
			
			float3 Whiteout(float3 a, float3 b)
			{
				return normalize(float3(a.rg + b.rg, a.b * b.b));
			}
			
	float4 MainPs( PixelInput i ) : SV_Target0
	{
		
		Material m = Material::Init();
		m.Albedo = float3( 1, 1, 1 );
		m.Normal = float3( 0, 0, 1 );
		m.Roughness = 1;
		m.Metalness = 0;
		m.AmbientOcclusion = 1;
		m.TintMask = 1;
		m.Opacity = 1;
		m.Emission = float3( 0, 0, 0 );
		m.Transmission = 0;
		
		float2 l_0 = i.vTextureCoords.xy * float2( 1, 1 );
		float4 l_1 = Tex2DS( g_tSurfacesAlbedoBase, g_sSampler0, l_0 );
		float l_2 = g_flSurfacesAlbedoHueBase;
		float l_3 = g_flSurfacesAlbedoSaturationBase;
		float l_4 = g_flSurfacesAlbedoValueBase;
		float3 l_5 = HueSaturationValue( l_1.xyz, l_2, l_3, l_4 );
		float4 l_6 = g_vSurfacesTintBase;
		float l_7 = g_flSurfacesTintValueBase;
		float4 l_8 = saturate( lerp( float4( l_5, 0 ), min( 1.0f, (float4( l_5, 0 )) + (l_6) ), l_7 ) );
		float4 l_9 = saturate( lerp( float4( l_5, 0 ), Divide_blend( float4( l_5, 0 ), l_6 ), l_7 ) );
		float4 l_10 = saturate( lerp( float4( l_5, 0 ), max( 0.0f, (float4( l_5, 0 )) - (l_6) ), l_7 ) );
		float4 l_11 = saturate( lerp( float4( l_5, 0 ), (float4( l_5, 0 )) + (l_6) - 2.0f * (float4( l_5, 0 )) * (l_6), l_7 ) );
		float4 l_12 = saturate( lerp( float4( l_5, 0 ), abs( (float4( l_5, 0 )) - (l_6) ), l_7 ) );
		float4 l_13 = saturate( lerp( float4( l_5, 0 ), HardMix_blend( float4( l_5, 0 ), l_6 ), l_7 ) );
		float4 l_14 = saturate( lerp( float4( l_5, 0 ), LinearLight_blend( float4( l_5, 0 ), l_6 ), l_7 ) );
		float4 l_15 = saturate( lerp( float4( l_5, 0 ), VividLight_blend( float4( l_5, 0 ), l_6 ), l_7 ) );
		float4 l_16 = saturate( lerp( float4( l_5, 0 ), HardLight_blend( float4( l_5, 0 ), l_6 ), l_7 ) );
		float4 l_17 = saturate( lerp( float4( l_5, 0 ), SoftLight_blend( float4( l_5, 0 ), l_6 ), l_7 ) );
		float4 l_18 = saturate( lerp( float4( l_5, 0 ), Overlay_blend( float4( l_5, 0 ), l_6 ), l_7 ) );
		float4 l_19 = saturate( lerp( float4( l_5, 0 ), LinearDodge_blend( float4( l_5, 0 ), l_6 ), l_7 ) );
		float4 l_20 = saturate( lerp( float4( l_5, 0 ), ColorDodge_blend( float4( l_5, 0 ), l_6 ), l_7 ) );
		float4 l_21 = saturate( lerp( float4( l_5, 0 ), (float4( l_5, 0 )) + (l_6) - (float4( l_5, 0 )) * (l_6), l_7 ) );
		float4 l_22 = saturate( lerp( float4( l_5, 0 ), max( float4( l_5, 0 ), l_6 ), l_7 ) );
		float4 l_23 = saturate( lerp( float4( l_5, 0 ), LinearBurn_blend( float4( l_5, 0 ), l_6 ), l_7 ) );
		float4 l_24 = saturate( lerp( float4( l_5, 0 ), ColorBurn_blend( float4( l_5, 0 ), l_6 ), l_7 ) );
		float4 l_25 = saturate( lerp( float4( l_5, 0 ), float4( l_5, 0 )*l_6, l_7 ) );
		float4 l_26 = saturate( lerp( float4( l_5, 0 ), min( float4( l_5, 0 ), l_6 ), l_7 ) );
		float4 l_27 = saturate( lerp( float4( l_5, 0 ), l_6, l_7 ) );
		float l_28 = g_flSurfacesTintModeBase;
		float4 l_29 = l_28 > 0 ? l_27 : float4( l_5, 0 );
		float4 l_30 = l_28 > 1 ? l_26 : l_29;
		float4 l_31 = l_28 > 2 ? l_25 : l_30;
		float4 l_32 = l_28 > 3 ? l_24 : l_31;
		float4 l_33 = l_28 > 4 ? l_23 : l_32;
		float4 l_34 = l_28 > 5 ? l_22 : l_33;
		float4 l_35 = l_28 > 6 ? l_21 : l_34;
		float4 l_36 = l_28 > 7 ? l_20 : l_35;
		float4 l_37 = l_28 > 8 ? l_19 : l_36;
		float4 l_38 = l_28 > 9 ? l_18 : l_37;
		float4 l_39 = l_28 > 10 ? l_17 : l_38;
		float4 l_40 = l_28 > 11 ? l_16 : l_39;
		float4 l_41 = l_28 > 12 ? l_15 : l_40;
		float4 l_42 = l_28 > 13 ? l_14 : l_41;
		float4 l_43 = l_28 > 14 ? l_13 : l_42;
		float4 l_44 = l_28 > 15 ? l_12 : l_43;
		float4 l_45 = l_28 > 16 ? l_11 : l_44;
		float4 l_46 = l_28 > 17 ? l_10 : l_45;
		float4 l_47 = l_28 > 18 ? l_9 : l_46;
		float4 l_48 = l_28 > 19 ? l_8 : l_47;
		float4 l_49 = Tex2DS( g_tSurfacesTintMaskBase, g_sSampler0, l_0 );
		float4 l_50 = saturate( lerp( float4( l_5, 0 ), l_48, l_49 ) );
		float3 l_51 = i.vPaintValues.rgb;
		float l_52 = g_flSurfacesVertexTintValueBase;
		float4 l_53 = saturate( lerp( l_50, min( 1.0f, (l_50) + (float4( l_51, 0 )) ), l_52 ) );
		float4 l_54 = saturate( lerp( l_50, Divide_blend( l_50, float4( l_51, 0 ) ), l_52 ) );
		float4 l_55 = saturate( lerp( l_50, max( 0.0f, (l_50) - (float4( l_51, 0 )) ), l_52 ) );
		float4 l_56 = saturate( lerp( l_50, (l_50) + (float4( l_51, 0 )) - 2.0f * (l_50) * (float4( l_51, 0 )), l_52 ) );
		float4 l_57 = saturate( lerp( l_50, abs( (l_50) - (float4( l_51, 0 )) ), l_52 ) );
		float4 l_58 = saturate( lerp( l_50, HardMix_blend( l_50, float4( l_51, 0 ) ), l_52 ) );
		float4 l_59 = saturate( lerp( l_50, LinearLight_blend( l_50, float4( l_51, 0 ) ), l_52 ) );
		float4 l_60 = saturate( lerp( l_50, VividLight_blend( l_50, float4( l_51, 0 ) ), l_52 ) );
		float4 l_61 = saturate( lerp( l_50, HardLight_blend( l_50, float4( l_51, 0 ) ), l_52 ) );
		float4 l_62 = saturate( lerp( l_50, SoftLight_blend( l_50, float4( l_51, 0 ) ), l_52 ) );
		float4 l_63 = saturate( lerp( l_50, Overlay_blend( l_50, float4( l_51, 0 ) ), l_52 ) );
		float4 l_64 = saturate( lerp( l_50, LinearDodge_blend( l_50, float4( l_51, 0 ) ), l_52 ) );
		float4 l_65 = saturate( lerp( l_50, ColorDodge_blend( l_50, float4( l_51, 0 ) ), l_52 ) );
		float4 l_66 = saturate( lerp( l_50, (l_50) + (float4( l_51, 0 )) - (l_50) * (float4( l_51, 0 )), l_52 ) );
		float4 l_67 = saturate( lerp( l_50, max( l_50, float4( l_51, 0 ) ), l_52 ) );
		float4 l_68 = saturate( lerp( l_50, LinearBurn_blend( l_50, float4( l_51, 0 ) ), l_52 ) );
		float4 l_69 = saturate( lerp( l_50, ColorBurn_blend( l_50, float4( l_51, 0 ) ), l_52 ) );
		float4 l_70 = saturate( lerp( l_50, l_50*float4( l_51, 0 ), l_52 ) );
		float4 l_71 = saturate( lerp( l_50, min( l_50, float4( l_51, 0 ) ), l_52 ) );
		float4 l_72 = saturate( lerp( l_50, float4( l_51, 0 ), l_52 ) );
		float l_73 = g_flSurfacesVertexTintModeBase;
		float4 l_74 = l_73 > 0 ? l_72 : l_50;
		float4 l_75 = l_73 > 1 ? l_71 : l_74;
		float4 l_76 = l_73 > 2 ? l_70 : l_75;
		float4 l_77 = l_73 > 3 ? l_69 : l_76;
		float4 l_78 = l_73 > 4 ? l_68 : l_77;
		float4 l_79 = l_73 > 5 ? l_67 : l_78;
		float4 l_80 = l_73 > 6 ? l_66 : l_79;
		float4 l_81 = l_73 > 7 ? l_65 : l_80;
		float4 l_82 = l_73 > 8 ? l_64 : l_81;
		float4 l_83 = l_73 > 9 ? l_63 : l_82;
		float4 l_84 = l_73 > 10 ? l_62 : l_83;
		float4 l_85 = l_73 > 11 ? l_61 : l_84;
		float4 l_86 = l_73 > 12 ? l_60 : l_85;
		float4 l_87 = l_73 > 13 ? l_59 : l_86;
		float4 l_88 = l_73 > 14 ? l_58 : l_87;
		float4 l_89 = l_73 > 15 ? l_57 : l_88;
		float4 l_90 = l_73 > 16 ? l_56 : l_89;
		float4 l_91 = l_73 > 17 ? l_55 : l_90;
		float4 l_92 = l_73 > 18 ? l_54 : l_91;
		float4 l_93 = l_73 > 19 ? l_53 : l_92;
		float4 l_94 = saturate( lerp( l_93, l_50, l_49 ) );
		float l_95 = g_flUseTintMaskInVertexPaintBase;
		float4 l_96 = saturate( lerp( l_93, l_94, l_95 ) );
		float4 l_97 = Tex2DS( g_tSurfacesAlbedoA, g_sSampler0, l_0 );
		float l_98 = g_flSurfacesAlbedoHueA;
		float l_99 = g_flSurfacesAlbedoSaturationA;
		float l_100 = g_flSurfacesAlbedoValueA;
		float3 l_101 = HueSaturationValue( l_97.xyz, l_98, l_99, l_100 );
		float4 l_102 = g_vSurfacesTintA;
		float l_103 = g_flSurfacesTintValueA;
		float4 l_104 = saturate( lerp( float4( l_101, 0 ), min( 1.0f, (float4( l_101, 0 )) + (l_102) ), l_103 ) );
		float4 l_105 = saturate( lerp( float4( l_101, 0 ), Divide_blend( float4( l_101, 0 ), l_102 ), l_103 ) );
		float4 l_106 = saturate( lerp( float4( l_101, 0 ), max( 0.0f, (float4( l_101, 0 )) - (l_102) ), l_103 ) );
		float4 l_107 = saturate( lerp( float4( l_101, 0 ), (float4( l_101, 0 )) + (l_102) - 2.0f * (float4( l_101, 0 )) * (l_102), l_103 ) );
		float4 l_108 = saturate( lerp( float4( l_101, 0 ), abs( (float4( l_101, 0 )) - (l_102) ), l_103 ) );
		float4 l_109 = saturate( lerp( float4( l_101, 0 ), HardMix_blend( float4( l_101, 0 ), l_102 ), l_103 ) );
		float4 l_110 = saturate( lerp( float4( l_101, 0 ), LinearLight_blend( float4( l_101, 0 ), l_102 ), l_103 ) );
		float4 l_111 = saturate( lerp( float4( l_101, 0 ), VividLight_blend( float4( l_101, 0 ), l_102 ), l_103 ) );
		float4 l_112 = saturate( lerp( float4( l_101, 0 ), HardLight_blend( float4( l_101, 0 ), l_102 ), l_103 ) );
		float4 l_113 = saturate( lerp( float4( l_101, 0 ), SoftLight_blend( float4( l_101, 0 ), l_102 ), l_103 ) );
		float4 l_114 = saturate( lerp( float4( l_101, 0 ), Overlay_blend( float4( l_101, 0 ), l_102 ), l_103 ) );
		float4 l_115 = saturate( lerp( float4( l_101, 0 ), LinearDodge_blend( float4( l_101, 0 ), l_102 ), l_103 ) );
		float4 l_116 = saturate( lerp( float4( l_101, 0 ), ColorDodge_blend( float4( l_101, 0 ), l_102 ), l_103 ) );
		float4 l_117 = saturate( lerp( float4( l_101, 0 ), (float4( l_101, 0 )) + (l_102) - (float4( l_101, 0 )) * (l_102), l_103 ) );
		float4 l_118 = saturate( lerp( float4( l_101, 0 ), max( float4( l_101, 0 ), l_102 ), l_103 ) );
		float4 l_119 = saturate( lerp( float4( l_101, 0 ), LinearBurn_blend( float4( l_101, 0 ), l_102 ), l_103 ) );
		float4 l_120 = saturate( lerp( float4( l_101, 0 ), ColorBurn_blend( float4( l_101, 0 ), l_102 ), l_103 ) );
		float4 l_121 = saturate( lerp( float4( l_101, 0 ), float4( l_101, 0 )*l_102, l_103 ) );
		float4 l_122 = saturate( lerp( float4( l_101, 0 ), min( float4( l_101, 0 ), l_102 ), l_103 ) );
		float4 l_123 = saturate( lerp( float4( l_101, 0 ), l_102, l_103 ) );
		float l_124 = g_flSurfacesTintModeA;
		float4 l_125 = l_124 > 0 ? l_123 : float4( l_101, 0 );
		float4 l_126 = l_124 > 1 ? l_122 : l_125;
		float4 l_127 = l_124 > 2 ? l_121 : l_126;
		float4 l_128 = l_124 > 3 ? l_120 : l_127;
		float4 l_129 = l_124 > 4 ? l_119 : l_128;
		float4 l_130 = l_124 > 5 ? l_118 : l_129;
		float4 l_131 = l_124 > 6 ? l_117 : l_130;
		float4 l_132 = l_124 > 7 ? l_116 : l_131;
		float4 l_133 = l_124 > 8 ? l_115 : l_132;
		float4 l_134 = l_124 > 9 ? l_114 : l_133;
		float4 l_135 = l_124 > 10 ? l_113 : l_134;
		float4 l_136 = l_124 > 11 ? l_112 : l_135;
		float4 l_137 = l_124 > 12 ? l_111 : l_136;
		float4 l_138 = l_124 > 13 ? l_110 : l_137;
		float4 l_139 = l_124 > 14 ? l_109 : l_138;
		float4 l_140 = l_124 > 15 ? l_108 : l_139;
		float4 l_141 = l_124 > 16 ? l_107 : l_140;
		float4 l_142 = l_124 > 17 ? l_106 : l_141;
		float4 l_143 = l_124 > 18 ? l_105 : l_142;
		float4 l_144 = l_124 > 19 ? l_104 : l_143;
		float4 l_145 = Tex2DS( g_tSurfacesTintMaskA, g_sSampler0, l_0 );
		float4 l_146 = saturate( lerp( float4( l_101, 0 ), l_144, l_145 ) );
		float l_147 = g_flSurfacesVertexTintValueA;
		float4 l_148 = saturate( lerp( l_146, min( 1.0f, (l_146) + (float4( l_51, 0 )) ), l_147 ) );
		float4 l_149 = saturate( lerp( l_146, Divide_blend( l_146, float4( l_51, 0 ) ), l_147 ) );
		float4 l_150 = saturate( lerp( l_146, max( 0.0f, (l_146) - (float4( l_51, 0 )) ), l_147 ) );
		float4 l_151 = saturate( lerp( l_146, (l_146) + (float4( l_51, 0 )) - 2.0f * (l_146) * (float4( l_51, 0 )), l_147 ) );
		float4 l_152 = saturate( lerp( l_146, abs( (l_146) - (float4( l_51, 0 )) ), l_147 ) );
		float4 l_153 = saturate( lerp( l_146, HardMix_blend( l_146, float4( l_51, 0 ) ), l_147 ) );
		float4 l_154 = saturate( lerp( l_146, LinearLight_blend( l_146, float4( l_51, 0 ) ), l_147 ) );
		float4 l_155 = saturate( lerp( l_146, VividLight_blend( l_146, float4( l_51, 0 ) ), l_147 ) );
		float4 l_156 = saturate( lerp( l_146, HardLight_blend( l_146, float4( l_51, 0 ) ), l_147 ) );
		float4 l_157 = saturate( lerp( l_146, SoftLight_blend( l_146, float4( l_51, 0 ) ), l_147 ) );
		float4 l_158 = saturate( lerp( l_146, Overlay_blend( l_146, float4( l_51, 0 ) ), l_147 ) );
		float4 l_159 = saturate( lerp( l_146, LinearDodge_blend( l_146, float4( l_51, 0 ) ), l_147 ) );
		float4 l_160 = saturate( lerp( l_146, ColorDodge_blend( l_146, float4( l_51, 0 ) ), l_147 ) );
		float4 l_161 = saturate( lerp( l_146, (l_146) + (float4( l_51, 0 )) - (l_146) * (float4( l_51, 0 )), l_147 ) );
		float4 l_162 = saturate( lerp( l_146, max( l_146, float4( l_51, 0 ) ), l_147 ) );
		float4 l_163 = saturate( lerp( l_146, LinearBurn_blend( l_146, float4( l_51, 0 ) ), l_147 ) );
		float4 l_164 = saturate( lerp( l_146, ColorBurn_blend( l_146, float4( l_51, 0 ) ), l_147 ) );
		float4 l_165 = saturate( lerp( l_146, l_146*float4( l_51, 0 ), l_147 ) );
		float4 l_166 = saturate( lerp( l_146, min( l_146, float4( l_51, 0 ) ), l_147 ) );
		float4 l_167 = saturate( lerp( l_146, float4( l_51, 0 ), l_147 ) );
		float l_168 = g_flSurfacesVertexTintModeA;
		float4 l_169 = l_168 > 0 ? l_167 : l_146;
		float4 l_170 = l_168 > 1 ? l_166 : l_169;
		float4 l_171 = l_168 > 2 ? l_165 : l_170;
		float4 l_172 = l_168 > 3 ? l_164 : l_171;
		float4 l_173 = l_168 > 4 ? l_163 : l_172;
		float4 l_174 = l_168 > 5 ? l_162 : l_173;
		float4 l_175 = l_168 > 6 ? l_161 : l_174;
		float4 l_176 = l_168 > 7 ? l_160 : l_175;
		float4 l_177 = l_168 > 8 ? l_159 : l_176;
		float4 l_178 = l_168 > 9 ? l_158 : l_177;
		float4 l_179 = l_168 > 10 ? l_157 : l_178;
		float4 l_180 = l_168 > 11 ? l_156 : l_179;
		float4 l_181 = l_168 > 12 ? l_155 : l_180;
		float4 l_182 = l_168 > 13 ? l_154 : l_181;
		float4 l_183 = l_168 > 14 ? l_153 : l_182;
		float4 l_184 = l_168 > 15 ? l_152 : l_183;
		float4 l_185 = l_168 > 16 ? l_151 : l_184;
		float4 l_186 = l_168 > 17 ? l_150 : l_185;
		float4 l_187 = l_168 > 18 ? l_149 : l_186;
		float4 l_188 = l_168 > 19 ? l_148 : l_187;
		float4 l_189 = saturate( lerp( l_188, l_146, l_145 ) );
		float l_190 = g_flUseTintMaskInVertexPaintA;
		float4 l_191 = saturate( lerp( l_188, l_189, l_190 ) );
		float4 l_192 = Tex2DS( g_tSurfacesBlendA, g_sSampler0, l_0 );
		float l_193 = i.vBlendValues.r;
		float l_194 = i.vBlendValues.g;
		float l_195 = i.vBlendValues.b;
		float3 l_196 = float3( l_193, l_194, l_195 );
		float3 l_197 = i.vColor.rgb;
		float l_198 = g_flUseModelsVertexColor;
		float3 l_199 = saturate( lerp( l_196, l_197, l_198 ) );
		float l_200 = l_199.x;
		float l_201 = g_flSurfacesBlendSoftnessA;
		float l_202 = saturate( ( l_201 - 0.001 ) / ( 1 - 0.001 ) ) * ( 1 - 0 ) + 0;
		float l_203 = 2 * l_202;
		float l_204 = l_203 + 1;
		float l_205 = l_200 * l_204;
		float l_206 = l_205 - l_202;
		float l_207 = l_206 - l_202;
		float4 l_208 = l_192 - float4( l_207, l_207, l_207, l_207 );
		float4 l_209 = l_208 / float4( l_203, l_203, l_203, l_203 );
		float4 l_210 = saturate( l_209 );
		float4 l_211 = 1 - l_210;
		float4 l_212 = saturate( lerp( l_96, l_191, l_211 ) );
		float4 l_213 = Tex2DS( g_tSurfacesAlbedoB, g_sSampler0, l_0 );
		float l_214 = g_flSurfacesAlbedoHueB;
		float l_215 = g_flSurfacesAlbedoSaturationB;
		float l_216 = g_flSurfacesAlbedoValueB;
		float3 l_217 = HueSaturationValue( l_213.xyz, l_214, l_215, l_216 );
		float4 l_218 = g_vSurfacesTintB;
		float l_219 = g_flSurfacesTintValueB;
		float4 l_220 = saturate( lerp( float4( l_217, 0 ), min( 1.0f, (float4( l_217, 0 )) + (l_218) ), l_219 ) );
		float4 l_221 = saturate( lerp( float4( l_217, 0 ), Divide_blend( float4( l_217, 0 ), l_218 ), l_219 ) );
		float4 l_222 = saturate( lerp( float4( l_217, 0 ), max( 0.0f, (float4( l_217, 0 )) - (l_218) ), l_219 ) );
		float4 l_223 = saturate( lerp( float4( l_217, 0 ), (float4( l_217, 0 )) + (l_218) - 2.0f * (float4( l_217, 0 )) * (l_218), l_219 ) );
		float4 l_224 = saturate( lerp( float4( l_217, 0 ), abs( (float4( l_217, 0 )) - (l_218) ), l_219 ) );
		float4 l_225 = saturate( lerp( float4( l_217, 0 ), HardMix_blend( float4( l_217, 0 ), l_218 ), l_219 ) );
		float4 l_226 = saturate( lerp( float4( l_217, 0 ), LinearLight_blend( float4( l_217, 0 ), l_218 ), l_219 ) );
		float4 l_227 = saturate( lerp( float4( l_217, 0 ), VividLight_blend( float4( l_217, 0 ), l_218 ), l_219 ) );
		float4 l_228 = saturate( lerp( float4( l_217, 0 ), HardLight_blend( float4( l_217, 0 ), l_218 ), l_219 ) );
		float4 l_229 = saturate( lerp( float4( l_217, 0 ), SoftLight_blend( float4( l_217, 0 ), l_218 ), l_219 ) );
		float4 l_230 = saturate( lerp( float4( l_217, 0 ), Overlay_blend( float4( l_217, 0 ), l_218 ), l_219 ) );
		float4 l_231 = saturate( lerp( float4( l_217, 0 ), LinearDodge_blend( float4( l_217, 0 ), l_218 ), l_219 ) );
		float4 l_232 = saturate( lerp( float4( l_217, 0 ), ColorDodge_blend( float4( l_217, 0 ), l_218 ), l_219 ) );
		float4 l_233 = saturate( lerp( float4( l_217, 0 ), (float4( l_217, 0 )) + (l_218) - (float4( l_217, 0 )) * (l_218), l_219 ) );
		float4 l_234 = saturate( lerp( float4( l_217, 0 ), max( float4( l_217, 0 ), l_218 ), l_219 ) );
		float4 l_235 = saturate( lerp( float4( l_217, 0 ), LinearBurn_blend( float4( l_217, 0 ), l_218 ), l_219 ) );
		float4 l_236 = saturate( lerp( float4( l_217, 0 ), ColorBurn_blend( float4( l_217, 0 ), l_218 ), l_219 ) );
		float4 l_237 = saturate( lerp( float4( l_217, 0 ), float4( l_217, 0 )*l_218, l_219 ) );
		float4 l_238 = saturate( lerp( float4( l_217, 0 ), min( float4( l_217, 0 ), l_218 ), l_219 ) );
		float4 l_239 = saturate( lerp( float4( l_217, 0 ), l_218, l_219 ) );
		float l_240 = g_flSurfacesTintModeB;
		float4 l_241 = l_240 > 0 ? l_239 : float4( l_217, 0 );
		float4 l_242 = l_240 > 1 ? l_238 : l_241;
		float4 l_243 = l_240 > 2 ? l_237 : l_242;
		float4 l_244 = l_240 > 3 ? l_236 : l_243;
		float4 l_245 = l_240 > 4 ? l_235 : l_244;
		float4 l_246 = l_240 > 5 ? l_234 : l_245;
		float4 l_247 = l_240 > 6 ? l_233 : l_246;
		float4 l_248 = l_240 > 7 ? l_232 : l_247;
		float4 l_249 = l_240 > 8 ? l_231 : l_248;
		float4 l_250 = l_240 > 9 ? l_230 : l_249;
		float4 l_251 = l_240 > 10 ? l_229 : l_250;
		float4 l_252 = l_240 > 11 ? l_228 : l_251;
		float4 l_253 = l_240 > 12 ? l_227 : l_252;
		float4 l_254 = l_240 > 13 ? l_226 : l_253;
		float4 l_255 = l_240 > 14 ? l_225 : l_254;
		float4 l_256 = l_240 > 15 ? l_224 : l_255;
		float4 l_257 = l_240 > 16 ? l_223 : l_256;
		float4 l_258 = l_240 > 17 ? l_222 : l_257;
		float4 l_259 = l_240 > 18 ? l_221 : l_258;
		float4 l_260 = l_240 > 19 ? l_220 : l_259;
		float4 l_261 = Tex2DS( g_tSurfacesTintMaskB, g_sSampler0, l_0 );
		float4 l_262 = saturate( lerp( float4( l_217, 0 ), l_260, l_261 ) );
		float l_263 = g_flSurfacesVertexTintModeB;
		float4 l_264 = saturate( lerp( l_262, min( 1.0f, (l_262) + (float4( l_263, l_263, l_263, l_263 )) ), float4( l_51, 0 ) ) );
		float4 l_265 = saturate( lerp( l_262, Divide_blend( l_262, float4( l_263, l_263, l_263, l_263 ) ), float4( l_51, 0 ) ) );
		float4 l_266 = saturate( lerp( l_262, max( 0.0f, (l_262) - (float4( l_263, l_263, l_263, l_263 )) ), float4( l_51, 0 ) ) );
		float4 l_267 = saturate( lerp( l_262, (l_262) + (float4( l_263, l_263, l_263, l_263 )) - 2.0f * (l_262) * (float4( l_263, l_263, l_263, l_263 )), float4( l_51, 0 ) ) );
		float4 l_268 = saturate( lerp( l_262, abs( (l_262) - (float4( l_263, l_263, l_263, l_263 )) ), float4( l_51, 0 ) ) );
		float4 l_269 = saturate( lerp( l_262, HardMix_blend( l_262, float4( l_263, l_263, l_263, l_263 ) ), float4( l_51, 0 ) ) );
		float4 l_270 = saturate( lerp( l_262, LinearLight_blend( l_262, float4( l_263, l_263, l_263, l_263 ) ), float4( l_51, 0 ) ) );
		float4 l_271 = saturate( lerp( l_262, VividLight_blend( l_262, float4( l_263, l_263, l_263, l_263 ) ), float4( l_51, 0 ) ) );
		float4 l_272 = saturate( lerp( l_262, HardLight_blend( l_262, float4( l_263, l_263, l_263, l_263 ) ), float4( l_51, 0 ) ) );
		float4 l_273 = saturate( lerp( l_262, SoftLight_blend( l_262, float4( l_263, l_263, l_263, l_263 ) ), float4( l_51, 0 ) ) );
		float4 l_274 = saturate( lerp( l_262, Overlay_blend( l_262, float4( l_263, l_263, l_263, l_263 ) ), float4( l_51, 0 ) ) );
		float4 l_275 = saturate( lerp( l_262, LinearDodge_blend( l_262, float4( l_263, l_263, l_263, l_263 ) ), float4( l_51, 0 ) ) );
		float4 l_276 = saturate( lerp( l_262, ColorDodge_blend( l_262, float4( l_263, l_263, l_263, l_263 ) ), float4( l_51, 0 ) ) );
		float4 l_277 = saturate( lerp( l_262, (l_262) + (float4( l_263, l_263, l_263, l_263 )) - (l_262) * (float4( l_263, l_263, l_263, l_263 )), float4( l_51, 0 ) ) );
		float4 l_278 = saturate( lerp( l_262, max( l_262, float4( l_263, l_263, l_263, l_263 ) ), float4( l_51, 0 ) ) );
		float4 l_279 = saturate( lerp( l_262, LinearBurn_blend( l_262, float4( l_263, l_263, l_263, l_263 ) ), float4( l_51, 0 ) ) );
		float4 l_280 = saturate( lerp( l_262, ColorBurn_blend( l_262, float4( l_263, l_263, l_263, l_263 ) ), float4( l_51, 0 ) ) );
		float4 l_281 = saturate( lerp( l_262, l_262*float4( l_263, l_263, l_263, l_263 ), float4( l_51, 0 ) ) );
		float4 l_282 = saturate( lerp( l_262, min( l_262, float4( l_263, l_263, l_263, l_263 ) ), float4( l_51, 0 ) ) );
		float4 l_283 = saturate( lerp( l_262, float4( l_263, l_263, l_263, l_263 ), float4( l_51, 0 ) ) );
		float l_284 = g_flSurfacesVertexTintValueB;
		float4 l_285 = l_284 > 0 ? l_283 : l_262;
		float4 l_286 = l_284 > 1 ? l_282 : l_285;
		float4 l_287 = l_284 > 2 ? l_281 : l_286;
		float4 l_288 = l_284 > 3 ? l_280 : l_287;
		float4 l_289 = l_284 > 4 ? l_279 : l_288;
		float4 l_290 = l_284 > 5 ? l_278 : l_289;
		float4 l_291 = l_284 > 6 ? l_277 : l_290;
		float4 l_292 = l_284 > 7 ? l_276 : l_291;
		float4 l_293 = l_284 > 8 ? l_275 : l_292;
		float4 l_294 = l_284 > 9 ? l_274 : l_293;
		float4 l_295 = l_284 > 10 ? l_273 : l_294;
		float4 l_296 = l_284 > 11 ? l_272 : l_295;
		float4 l_297 = l_284 > 12 ? l_271 : l_296;
		float4 l_298 = l_284 > 13 ? l_270 : l_297;
		float4 l_299 = l_284 > 14 ? l_269 : l_298;
		float4 l_300 = l_284 > 15 ? l_268 : l_299;
		float4 l_301 = l_284 > 16 ? l_267 : l_300;
		float4 l_302 = l_284 > 17 ? l_266 : l_301;
		float4 l_303 = l_284 > 18 ? l_265 : l_302;
		float4 l_304 = l_284 > 19 ? l_264 : l_303;
		float4 l_305 = saturate( lerp( l_304, l_262, l_261 ) );
		float l_306 = g_flUseTintMaskInVertexPaintB;
		float4 l_307 = saturate( lerp( l_304, l_305, l_306 ) );
		float4 l_308 = Tex2DS( g_tSurfacesBlendB, g_sSampler0, l_0 );
		float l_309 = l_199.y;
		float l_310 = g_flSurfacesBlendSoftnessB;
		float l_311 = saturate( ( l_310 - 0.001 ) / ( 1 - 0.001 ) ) * ( 1 - 0 ) + 0;
		float l_312 = 2 * l_311;
		float l_313 = l_312 + 1;
		float l_314 = l_309 * l_313;
		float l_315 = l_314 - l_311;
		float l_316 = l_315 - l_311;
		float4 l_317 = l_308 - float4( l_316, l_316, l_316, l_316 );
		float4 l_318 = l_317 / float4( l_312, l_312, l_312, l_312 );
		float4 l_319 = saturate( l_318 );
		float4 l_320 = 1 - l_319;
		float4 l_321 = saturate( lerp( l_212, l_307, l_320 ) );
		float l_322 = g_flSurfacesWetnessAlbedoHueBase;
		float l_323 = g_flSurfacesWetnessAlbedoSaturationBase;
		float l_324 = g_flSurfacesWetnessAlbedoValueBase;
		float l_325 = g_flSurfacesWetnessRoughnessValueBase;
		float4 l_326 = float4( l_322, l_323, l_324, l_325 );
		float l_327 = g_flSurfacesWetnessAlbedoHueA;
		float l_328 = g_flSurfacesWetnessAlbedoSaturationA;
		float l_329 = g_flSurfacesWetnessAlbedoValueA;
		float l_330 = g_flSurfacesWetnessRoughnessValueA;
		float4 l_331 = float4( l_327, l_328, l_329, l_330 );
		float4 l_332 = lerp( l_326, l_331, l_211 );
		float l_333 = g_flSurfacesWetnessAlbedoHueB;
		float l_334 = g_flSurfacesWetnessAlbedoSaturationB;
		float l_335 = g_flSurfacesWetnessAlbedoValueB;
		float l_336 = g_flSurfacesWetnessRoughnessValueB;
		float4 l_337 = float4( l_333, l_334, l_335, l_336 );
		float4 l_338 = lerp( l_332, l_337, l_320 );
		float l_339 = l_338.x;
		float l_340 = l_338.y;
		float l_341 = l_338.z;
		float3 l_342 = HueSaturationValue( l_321.xyz, l_339, l_340, l_341 );
		float3 l_343 = saturate( l_342 );
		float l_344 = g_flSurfacesWetnessLayers;
		float4 l_345 = Tex2DS( g_tSurfacesCracksBase, g_sSampler0, l_0 );
		float4 l_346 = Tex2DS( g_tSurfacesAmbientOcclusionBase, g_sSampler0, l_0 );
		float4 l_347 = 1 - l_346;
		float l_348 = g_flGenerateCracksFromInvertedAmbientOcclusionBase;
		float4 l_349 = saturate( lerp( l_345, l_347, l_348 ) );
		float2 l_350 = g_vSurfacesCracksLevelsBase;
		float l_351 = l_350.x;
		float l_352 = l_350.y;
		float4 l_353 = saturate( ( l_349 - float4( l_351, l_351, l_351, l_351 ) ) / ( float4( l_352, l_352, l_352, l_352 ) - float4( l_351, l_351, l_351, l_351 ) ) ) * ( float4( 1, 1, 1, 1 ) - float4( 0, 0, 0, 0 ) ) + float4( 0, 0, 0, 0 );
		float4 l_354 = Tex2DS( g_tSurfacesCracksA, g_sSampler0, l_0 );
		float4 l_355 = Tex2DS( g_tSurfacesAmbientOcclusionA, g_sSampler0, l_0 );
		float4 l_356 = 1 - l_355;
		float l_357 = g_flGenerateCracksFromInvertedAmbientOcclusionA;
		float4 l_358 = saturate( lerp( l_354, l_356, l_357 ) );
		float2 l_359 = g_vSurfacesCracksLevelsA;
		float l_360 = l_359.x;
		float l_361 = l_359.y;
		float4 l_362 = saturate( ( l_358 - float4( l_360, l_360, l_360, l_360 ) ) / ( float4( l_361, l_361, l_361, l_361 ) - float4( l_360, l_360, l_360, l_360 ) ) ) * ( float4( 1, 1, 1, 1 ) - float4( 0, 0, 0, 0 ) ) + float4( 0, 0, 0, 0 );
		float4 l_363 = saturate( lerp( l_353, l_362, l_211 ) );
		float4 l_364 = Tex2DS( g_tSurfacesCracksB, g_sSampler0, l_0 );
		float4 l_365 = Tex2DS( g_tSurfacesAmbientOcclusionB, g_sSampler0, l_0 );
		float4 l_366 = 1 - l_365;
		float l_367 = g_flGenerateCracksFromInvertedAmbientOcclusionB;
		float4 l_368 = saturate( lerp( l_364, l_366, l_367 ) );
		float2 l_369 = g_vSurfacesCracksLevelsB;
		float l_370 = l_369.x;
		float l_371 = l_369.y;
		float4 l_372 = saturate( ( l_368 - float4( l_370, l_370, l_370, l_370 ) ) / ( float4( l_371, l_371, l_371, l_371 ) - float4( l_370, l_370, l_370, l_370 ) ) ) * ( float4( 1, 1, 1, 1 ) - float4( 0, 0, 0, 0 ) ) + float4( 0, 0, 0, 0 );
		float4 l_373 = saturate( lerp( l_363, l_372, l_320 ) );
		float4 l_374 = Tex2DS( g_tSurfacesBlendBase, g_sSampler0, l_0 );
		float4 l_375 = saturate( lerp( l_374, l_192, l_211 ) );
		float4 l_376 = saturate( lerp( l_375, l_308, l_320 ) );
		float3 l_377 = i.vPositionWithOffsetWs.xyz + g_vHighPrecisionLightingOffsetWs.xyz;
		float3 l_378 = l_377 * float3( 0.01, 0.01, 0.01 );
		float l_379 = g_flWaterPuddlesScale;
		float3 l_380 = l_378 * float3( l_379, l_379, l_379 );
		float l_381 = fBMNoise( l_380.xy, 4, 0.5, 3, 0 );
		float l_382 = g_flWaterPuddlesBlendSoftness;
		float l_383 = g_flWaterPuddlesAccumulation;
		float2 l_384 = float2( l_382, l_383 );
		float l_385 = l_384.y;
		float l_386 = l_381 - l_385;
		float l_387 = l_384.x;
		float l_388 = l_386 / l_387;
		float l_389 = saturate( l_388 );
		float l_390 = 1 - l_389;
		float l_391 = g_flWaterPuddlesContrast;
		float l_392 = saturate( ( l_391 - 0.001 ) / ( 1 - 0.001 ) ) * ( 1 - 0 ) + 0;
		float l_393 = 2 * l_392;
		float l_394 = l_393 + 1;
		float l_395 = l_390 * l_394;
		float l_396 = l_395 - l_392;
		float l_397 = l_396 - l_392;
		float4 l_398 = l_376 - float4( l_397, l_397, l_397, l_397 );
		float4 l_399 = l_398 / float4( l_393, l_393, l_393, l_393 );
		float4 l_400 = saturate( l_399 );
		float4 l_401 = 1 - l_400;
		float4 l_402 = l_373 + l_401;
		float4 l_403 = saturate( l_402 );
		float4 l_404 = float4( l_344, l_344, l_344, l_344 ) + l_403;
		float4 l_405 = saturate( l_404 );
		float4 l_406 = Tex2DS( g_tSurfacesPorounesssBase, g_sSampler0, l_0 );
		float4 l_407 = Tex2DS( g_tSurfacesMetalnessBase, g_sSampler0, l_0 );
		float4 l_408 = 1 - l_407;
		float l_409 = g_flGeneratePorousnessFromInvertedMetalnessBase;
		float4 l_410 = saturate( lerp( l_406, l_408, l_409 ) );
		float4 l_411 = Tex2DS( g_tSurfacesPorounesssA, g_sSampler0, l_0 );
		float4 l_412 = Tex2DS( g_tSurfacesMetalnessA, g_sSampler0, l_0 );
		float4 l_413 = 1 - l_412;
		float l_414 = g_flGeneratePorousnessFromInvertedMetalnessA;
		float4 l_415 = saturate( lerp( l_411, l_413, l_414 ) );
		float4 l_416 = saturate( lerp( l_410, l_415, l_211 ) );
		float4 l_417 = Tex2DS( g_tSurfacesPorounesssB, g_sSampler0, l_0 );
		float4 l_418 = Tex2DS( g_tSurfacesMetalnessB, g_sSampler0, l_0 );
		float4 l_419 = 1 - l_418;
		float l_420 = g_flGeneratePorousnessFromInvertedMetalnessB;
		float4 l_421 = saturate( lerp( l_417, l_419, l_420 ) );
		float4 l_422 = saturate( lerp( l_416, l_421, l_320 ) );
		float4 l_423 = l_405 * l_422;
		float4 l_424 = saturate( l_423 );
		float4 l_425 = lerp( l_321, float4( l_343, 0 ), l_424 );
		float4 l_426 = g_vWaterPuddlesAlbedo;
		float l_427 = g_flWaterPuddlesAlbedoHue;
		float l_428 = g_flWaterPuddlesAlbedoSaturation;
		float l_429 = g_flWaterPuddlesAlbedoValue;
		float3 l_430 = HueSaturationValue( l_426.xyz, l_427, l_428, l_429 );
		float l_431 = g_flWaterPuddlesAlbedoBlendValue;
		float4 l_432 = saturate( lerp( l_425, min( 1.0f, (l_425) + (float4( l_430, 0 )) ), l_431 ) );
		float4 l_433 = saturate( lerp( l_425, Divide_blend( l_425, float4( l_430, 0 ) ), l_431 ) );
		float4 l_434 = saturate( lerp( l_425, max( 0.0f, (l_425) - (float4( l_430, 0 )) ), l_431 ) );
		float4 l_435 = saturate( lerp( l_425, (l_425) + (float4( l_430, 0 )) - 2.0f * (l_425) * (float4( l_430, 0 )), l_431 ) );
		float4 l_436 = saturate( lerp( l_425, abs( (l_425) - (float4( l_430, 0 )) ), l_431 ) );
		float4 l_437 = saturate( lerp( l_425, HardMix_blend( l_425, float4( l_430, 0 ) ), l_431 ) );
		float4 l_438 = saturate( lerp( l_425, LinearLight_blend( l_425, float4( l_430, 0 ) ), l_431 ) );
		float4 l_439 = saturate( lerp( l_425, VividLight_blend( l_425, float4( l_430, 0 ) ), l_431 ) );
		float4 l_440 = saturate( lerp( l_425, HardLight_blend( l_425, float4( l_430, 0 ) ), l_431 ) );
		float4 l_441 = saturate( lerp( l_425, SoftLight_blend( l_425, float4( l_430, 0 ) ), l_431 ) );
		float4 l_442 = saturate( lerp( l_425, Overlay_blend( l_425, float4( l_430, 0 ) ), l_431 ) );
		float4 l_443 = saturate( lerp( l_425, LinearDodge_blend( l_425, float4( l_430, 0 ) ), l_431 ) );
		float4 l_444 = saturate( lerp( l_425, ColorDodge_blend( l_425, float4( l_430, 0 ) ), l_431 ) );
		float4 l_445 = saturate( lerp( l_425, (l_425) + (float4( l_430, 0 )) - (l_425) * (float4( l_430, 0 )), l_431 ) );
		float4 l_446 = saturate( lerp( l_425, max( l_425, float4( l_430, 0 ) ), l_431 ) );
		float4 l_447 = saturate( lerp( l_425, LinearBurn_blend( l_425, float4( l_430, 0 ) ), l_431 ) );
		float4 l_448 = saturate( lerp( l_425, ColorBurn_blend( l_425, float4( l_430, 0 ) ), l_431 ) );
		float4 l_449 = saturate( lerp( l_425, l_425*float4( l_430, 0 ), l_431 ) );
		float4 l_450 = saturate( lerp( l_425, min( l_425, float4( l_430, 0 ) ), l_431 ) );
		float4 l_451 = saturate( lerp( l_425, float4( l_430, 0 ), l_431 ) );
		float l_452 = g_flWaterPuddlesAlbedoBlendMode;
		float4 l_453 = l_452 > 0 ? l_451 : l_425;
		float4 l_454 = l_452 > 1 ? l_450 : l_453;
		float4 l_455 = l_452 > 2 ? l_449 : l_454;
		float4 l_456 = l_452 > 3 ? l_448 : l_455;
		float4 l_457 = l_452 > 4 ? l_447 : l_456;
		float4 l_458 = l_452 > 5 ? l_446 : l_457;
		float4 l_459 = l_452 > 6 ? l_445 : l_458;
		float4 l_460 = l_452 > 7 ? l_444 : l_459;
		float4 l_461 = l_452 > 8 ? l_443 : l_460;
		float4 l_462 = l_452 > 9 ? l_442 : l_461;
		float4 l_463 = l_452 > 10 ? l_441 : l_462;
		float4 l_464 = l_452 > 11 ? l_440 : l_463;
		float4 l_465 = l_452 > 12 ? l_439 : l_464;
		float4 l_466 = l_452 > 13 ? l_438 : l_465;
		float4 l_467 = l_452 > 14 ? l_437 : l_466;
		float4 l_468 = l_452 > 15 ? l_436 : l_467;
		float4 l_469 = l_452 > 16 ? l_435 : l_468;
		float4 l_470 = l_452 > 17 ? l_434 : l_469;
		float4 l_471 = l_452 > 18 ? l_433 : l_470;
		float4 l_472 = l_452 > 19 ? l_432 : l_471;
		float4 l_473 = saturate( lerp( l_425, l_472, l_403 ) );
		float4 l_474 = g_vRainRipplesAlbedo;
		float l_475 = g_flRainRipplesAlbedoHue;
		float l_476 = g_flRainRipplesAlbedoSaturation;
		float l_477 = g_flRainRipplesAlbedoValue;
		float3 l_478 = HueSaturationValue( l_474.xyz, l_475, l_476, l_477 );
		float l_479 = g_flRainRipplesAlbedoBlendValue;
		float4 l_480 = saturate( lerp( l_425, min( 1.0f, (l_425) + (float4( l_478, 0 )) ), l_479 ) );
		float4 l_481 = saturate( lerp( l_425, Divide_blend( l_425, float4( l_478, 0 ) ), l_479 ) );
		float4 l_482 = saturate( lerp( l_425, max( 0.0f, (l_425) - (float4( l_478, 0 )) ), l_479 ) );
		float4 l_483 = saturate( lerp( l_425, (l_425) + (float4( l_478, 0 )) - 2.0f * (l_425) * (float4( l_478, 0 )), l_479 ) );
		float4 l_484 = saturate( lerp( l_425, abs( (l_425) - (float4( l_478, 0 )) ), l_479 ) );
		float4 l_485 = saturate( lerp( l_425, HardMix_blend( l_425, float4( l_478, 0 ) ), l_479 ) );
		float4 l_486 = saturate( lerp( l_425, LinearLight_blend( l_425, float4( l_478, 0 ) ), l_479 ) );
		float4 l_487 = saturate( lerp( l_425, VividLight_blend( l_425, float4( l_478, 0 ) ), l_479 ) );
		float4 l_488 = saturate( lerp( l_425, HardLight_blend( l_425, float4( l_478, 0 ) ), l_479 ) );
		float4 l_489 = saturate( lerp( l_425, SoftLight_blend( l_425, float4( l_478, 0 ) ), l_479 ) );
		float4 l_490 = saturate( lerp( l_425, Overlay_blend( l_425, float4( l_478, 0 ) ), l_479 ) );
		float4 l_491 = saturate( lerp( l_425, LinearDodge_blend( l_425, float4( l_478, 0 ) ), l_479 ) );
		float4 l_492 = saturate( lerp( l_425, ColorDodge_blend( l_425, float4( l_478, 0 ) ), l_479 ) );
		float4 l_493 = saturate( lerp( l_425, (l_425) + (float4( l_478, 0 )) - (l_425) * (float4( l_478, 0 )), l_479 ) );
		float4 l_494 = saturate( lerp( l_425, max( l_425, float4( l_478, 0 ) ), l_479 ) );
		float4 l_495 = saturate( lerp( l_425, LinearBurn_blend( l_425, float4( l_478, 0 ) ), l_479 ) );
		float4 l_496 = saturate( lerp( l_425, ColorBurn_blend( l_425, float4( l_478, 0 ) ), l_479 ) );
		float4 l_497 = saturate( lerp( l_425, l_425*float4( l_478, 0 ), l_479 ) );
		float4 l_498 = saturate( lerp( l_425, min( l_425, float4( l_478, 0 ) ), l_479 ) );
		float4 l_499 = saturate( lerp( l_425, float4( l_478, 0 ), l_479 ) );
		float l_500 = g_flRainRipplesAlbedoBlendMode;
		float4 l_501 = l_500 > 0 ? l_499 : l_425;
		float4 l_502 = l_500 > 1 ? l_498 : l_501;
		float4 l_503 = l_500 > 2 ? l_497 : l_502;
		float4 l_504 = l_500 > 3 ? l_496 : l_503;
		float4 l_505 = l_500 > 4 ? l_495 : l_504;
		float4 l_506 = l_500 > 5 ? l_494 : l_505;
		float4 l_507 = l_500 > 6 ? l_493 : l_506;
		float4 l_508 = l_500 > 7 ? l_492 : l_507;
		float4 l_509 = l_500 > 8 ? l_491 : l_508;
		float4 l_510 = l_500 > 9 ? l_490 : l_509;
		float4 l_511 = l_500 > 10 ? l_489 : l_510;
		float4 l_512 = l_500 > 11 ? l_488 : l_511;
		float4 l_513 = l_500 > 12 ? l_487 : l_512;
		float4 l_514 = l_500 > 13 ? l_486 : l_513;
		float4 l_515 = l_500 > 14 ? l_485 : l_514;
		float4 l_516 = l_500 > 15 ? l_484 : l_515;
		float4 l_517 = l_500 > 16 ? l_483 : l_516;
		float4 l_518 = l_500 > 17 ? l_482 : l_517;
		float4 l_519 = l_500 > 18 ? l_481 : l_518;
		float4 l_520 = l_500 > 19 ? l_480 : l_519;
		float l_521 = g_flRainRipplesIntensityBase;
		float l_522 = g_flRainRipplesRingsBase;
		float l_523 = g_flRainRipplesSizeBase;
		float l_524 = g_flRainRipplesStaticBase;
		float4 l_525 = float4( l_521, l_522, l_523, l_524 );
		float l_526 = g_flRainRipplesIntensityA;
		float l_527 = g_flRainRipplesRingsA;
		float l_528 = g_flRainRipplesSizeA;
		float l_529 = g_flRainRipplesStaticA;
		float4 l_530 = float4( l_526, l_527, l_528, l_529 );
		float4 l_531 = lerp( l_525, l_530, l_211 );
		float l_532 = g_flRainRipplesIntensityB;
		float l_533 = g_flRainRipplesRingsB;
		float l_534 = g_flRainRipplesSizeB;
		float l_535 = g_flRainRipplesStaticB;
		float4 l_536 = float4( l_532, l_533, l_534, l_535 );
		float4 l_537 = lerp( l_531, l_536, l_320 );
		float l_538 = l_537.z;
		float l_539 = g_flRainRipplesSize;
		float l_540 = g_flRainRipplesCutoff;
		float4 l_541 = saturate( ( l_403 - float4( l_540, l_540, l_540, l_540 ) ) / ( float4( l_540, l_540, l_540, l_540 ) - float4( l_540, l_540, l_540, l_540 ) ) ) * ( float4( 1, 1, 1, 1 ) - float4( 0, 0, 0, 0 ) ) + float4( 0, 0, 0, 0 );
		float l_542 = lerp( l_538, l_539, l_541.x );
		float l_543 = saturate( ( l_542 - 0 ) / ( 1 - 0 ) ) * ( 1 - -0.15 ) + -0.15;
		float l_544 = l_543 * 0.8;
		float l_545 = l_544 + 0.2;
		float l_546 = g_flRainRipplesRotationA;
		float3 l_547 = AxisDegrees( l_378, float3( 0, 0, 1 ), l_546 );
		float l_548 = g_flRainRipplesSpeedA;
		float l_549 = g_flTime * l_548;
		float2 l_550 = float2( l_549, 0 );
		float2 l_551 = TileAndOffsetUv( l_547.xy, float2( 1, 1 ), l_550 );
		float l_552 = l_537.w;
		float l_553 = g_flRainRipplesStatic;
		float l_554 = lerp( l_552, l_553, l_541.x );
		float l_555 = 1 - l_554;
		float l_556 = saturate( l_555 );
		float3 l_557 = lerp( l_547, float3( l_551, 0 ), l_556 );
		float l_558 = g_flRainRipplesScaleA;
		float2 l_559 = g_vRainRipplesLocationA;
		float2 l_560 = TileAndOffsetUv( l_557.xy, float2( l_558, l_558 ), l_559 );
		float4 l_561 = Tex2DS( g_tRainRipplesNormalOpacityTemporalA, g_sSampler0, l_560 );
		float l_562 = g_flRainRipplesLifespanA;
		float l_563 = g_flTime * l_562;
		float l_564 = g_flRainRipplesDelayA;
		float l_565 = saturate( ( l_564 - 0 ) / ( 1 - 0 ) ) * ( 0.01 - 1 ) + 1;
		float l_566 = l_563 * l_565;
		float l_567 = l_561.a + l_566;
		float l_568 = frac( l_567 );
		float l_569 = 1 - l_565;
		float l_570 = l_568 - l_569;
		float l_571 = 1 / l_565;
		float l_572 = l_570 * l_571;
		float l_573 = l_545 - l_572;
		float l_574 = saturate( l_573 );
		float l_575 = l_572 - 1;
		float l_576 = l_575 + l_561.b;
		float l_577 = l_576 * 20;
		float l_578 = Clamp( l_577, 0, 5 );
		float l_579 = l_537.y;
		float l_580 = g_flRainRipplesRings;
		float l_581 = lerp( l_579, l_580, l_541.x );
		float l_582 = l_581 == 2 ? 2.5132742 : 1.2566371;
		float l_583 = l_581 == 3 ? 3.1415927 : l_582;
		float l_584 = l_578 * l_583;
		float l_585 = sin( l_584 );
		float l_586 = l_574 * l_585;
		float4 l_587 = float4( 0, 0, 0, 1 );
		float l_588 = g_flRainRipplesLevel;
		float4 l_589 = l_588 > 0 ? float4( l_586, l_586, l_586, l_586 ) : l_587;
		float l_590 = saturate( ( l_542 - 0 ) / ( 1 - 0 ) ) * ( 1 - -0.15 ) + -0.15;
		float l_591 = l_590 * 0.8;
		float l_592 = l_591 + 0.2;
		float l_593 = g_flRainRipplesRotationB;
		float3 l_594 = AxisDegrees( l_378, float3( 0, 0, 1 ), l_593 );
		float l_595 = g_flRainRipplesSpeedB;
		float l_596 = g_flTime * l_595;
		float2 l_597 = float2( l_596, 0 );
		float2 l_598 = TileAndOffsetUv( l_594.xy, float2( 1, 1 ), l_597 );
		float3 l_599 = lerp( l_594, float3( l_598, 0 ), l_556 );
		float l_600 = g_flRainRipplesScaleB;
		float2 l_601 = g_vRainRipplesLocationB;
		float2 l_602 = TileAndOffsetUv( l_599.xy, float2( l_600, l_600 ), l_601 );
		float4 l_603 = Tex2DS( g_tRainRipplesNormalOpacityTemporalB, g_sSampler0, l_602 );
		float l_604 = g_flRainRipplesLifespanB;
		float l_605 = g_flTime * l_604;
		float l_606 = g_flRainRipplesDelayB;
		float l_607 = saturate( ( l_606 - 0 ) / ( 1 - 0 ) ) * ( 0.01 - 1 ) + 1;
		float l_608 = l_605 * l_607;
		float l_609 = l_603.a + l_608;
		float l_610 = frac( l_609 );
		float l_611 = 1 - l_607;
		float l_612 = l_610 - l_611;
		float l_613 = 1 / l_607;
		float l_614 = l_612 * l_613;
		float l_615 = l_592 - l_614;
		float l_616 = saturate( l_615 );
		float l_617 = l_614 - 1;
		float l_618 = l_617 + l_603.b;
		float l_619 = l_618 * 20;
		float l_620 = Clamp( l_619, 0, 5 );
		float l_621 = l_581 == 2 ? 2.5132742 : 1.2566371;
		float l_622 = l_581 == 3 ? 3.1415927 : l_621;
		float l_623 = l_620 * l_622;
		float l_624 = sin( l_623 );
		float l_625 = l_616 * l_624;
		float4 l_626 = l_589 + float4( l_625, l_625, l_625, l_625 );
		float4 l_627 = l_588 > 1 ? l_626 : l_589;
		float l_628 = saturate( ( l_542 - 0 ) / ( 1 - 0 ) ) * ( 1 - -0.15 ) + -0.15;
		float l_629 = l_628 * 0.8;
		float l_630 = l_629 + 0.2;
		float l_631 = g_flRainRipplesRotationC;
		float3 l_632 = AxisDegrees( l_378, float3( 0, 0, 1 ), l_631 );
		float l_633 = g_flRainRipplesSpeedC;
		float l_634 = g_flTime * l_633;
		float2 l_635 = float2( l_634, 0 );
		float2 l_636 = TileAndOffsetUv( l_632.xy, float2( 1, 1 ), l_635 );
		float3 l_637 = lerp( l_632, float3( l_636, 0 ), l_556 );
		float l_638 = g_flRainRipplesScaleC;
		float2 l_639 = g_vRainRipplesLocationC;
		float2 l_640 = TileAndOffsetUv( l_637.xy, float2( l_638, l_638 ), l_639 );
		float4 l_641 = Tex2DS( g_tRainRipplesNormalOpacityTemporalC, g_sSampler0, l_640 );
		float l_642 = g_flRainRipplesLifespanC;
		float l_643 = g_flTime * l_642;
		float l_644 = g_flRainRipplesDelayC;
		float l_645 = saturate( ( l_644 - 0 ) / ( 1 - 0 ) ) * ( 0.01 - 1 ) + 1;
		float l_646 = l_643 * l_645;
		float l_647 = l_641.a + l_646;
		float l_648 = frac( l_647 );
		float l_649 = 1 - l_645;
		float l_650 = l_648 - l_649;
		float l_651 = 1 / l_645;
		float l_652 = l_650 * l_651;
		float l_653 = l_630 - l_652;
		float l_654 = saturate( l_653 );
		float l_655 = l_652 - 1;
		float l_656 = l_655 + l_641.b;
		float l_657 = l_656 * 20;
		float l_658 = Clamp( l_657, 0, 5 );
		float l_659 = l_581 == 2 ? 2.5132742 : 1.2566371;
		float l_660 = l_581 == 3 ? 3.1415927 : l_659;
		float l_661 = l_658 * l_660;
		float l_662 = sin( l_661 );
		float l_663 = l_654 * l_662;
		float4 l_664 = l_627 + float4( l_663, l_663, l_663, l_663 );
		float4 l_665 = l_588 > 2 ? l_664 : l_627;
		float l_666 = saturate( ( l_542 - 0 ) / ( 1 - 0 ) ) * ( 1 - -0.15 ) + -0.15;
		float l_667 = l_666 * 0.8;
		float l_668 = l_667 + 0.2;
		float l_669 = g_flRainRipplesRotationD;
		float3 l_670 = AxisDegrees( l_378, float3( 0, 0, 1 ), l_669 );
		float l_671 = g_flRainRipplesSpeedD;
		float l_672 = g_flTime * l_671;
		float2 l_673 = float2( l_672, 0 );
		float2 l_674 = TileAndOffsetUv( l_670.xy, float2( 1, 1 ), l_673 );
		float3 l_675 = lerp( l_670, float3( l_674, 0 ), l_556 );
		float l_676 = g_flRainRipplesScaleD;
		float2 l_677 = g_vRainRipplesLocationD;
		float2 l_678 = TileAndOffsetUv( l_675.xy, float2( l_676, l_676 ), l_677 );
		float4 l_679 = Tex2DS( g_tRainRipplesNormalOpacityTemporalD, g_sSampler0, l_678 );
		float l_680 = g_flRainRipplesLifespanD;
		float l_681 = g_flTime * l_680;
		float l_682 = g_flRainRipplesDelayD;
		float l_683 = saturate( ( l_682 - 0 ) / ( 1 - 0 ) ) * ( 0.01 - 1 ) + 1;
		float l_684 = l_681 * l_683;
		float l_685 = l_679.a + l_684;
		float l_686 = frac( l_685 );
		float l_687 = 1 - l_683;
		float l_688 = l_686 - l_687;
		float l_689 = 1 / l_683;
		float l_690 = l_688 * l_689;
		float l_691 = l_668 - l_690;
		float l_692 = saturate( l_691 );
		float l_693 = l_690 - 1;
		float l_694 = l_693 + l_679.b;
		float l_695 = l_694 * 20;
		float l_696 = Clamp( l_695, 0, 5 );
		float l_697 = l_581 == 2 ? 2.5132742 : 1.2566371;
		float l_698 = l_581 == 3 ? 3.1415927 : l_697;
		float l_699 = l_696 * l_698;
		float l_700 = sin( l_699 );
		float l_701 = l_692 * l_700;
		float4 l_702 = l_665 + float4( l_701, l_701, l_701, l_701 );
		float4 l_703 = l_588 > 3 ? l_702 : l_665;
		float4 l_704 = saturate( l_703 );
		float4 l_705 = saturate( lerp( l_425, l_520, l_704 ) );
		float4 l_706 = l_704 - l_403;
		float4 l_707 = saturate( l_706 );
		float4 l_708 = saturate( lerp( l_473, l_705, l_707 ) );
		float l_709 = g_flWaterCausticsScaleA;
		float3 l_710 = l_378 * float3( l_709, l_709, l_709 );
		float l_711 = g_flWaterCausticsRotationA;
		float3 l_712 = AxisDegrees( l_710, float3( 0, 0, 1 ), l_711 );
		float l_713 = g_flWaterCausticsSpeedA;
		float l_714 = g_flTime * l_713;
		float2 l_715 = float2( l_714, 0 );
		float2 l_716 = TileAndOffsetUv( l_712.xy, float2( 1, 1 ), l_715 );
		float l_717 = g_flWaterCausticsNoiseDisplacementA;
		float l_718 = g_flWaterRipplesScaleA;
		float3 l_719 = l_378 * float3( l_718, l_718, l_718 );
		float l_720 = g_flWaterRipplesRotationA;
		float3 l_721 = AxisDegrees( l_719, float3( 0, 0, 1 ), l_720 );
		float l_722 = g_flWaterRipplesSpeedA;
		float l_723 = g_flTime * l_722;
		float2 l_724 = float2( l_723, 0 );
		float2 l_725 = TileAndOffsetUv( l_721.xy, float2( 1, 1 ), l_724 );
		float4 l_726 = Tex2DS( g_tWaterRipplesNormalA, g_sSampler0, l_725 );
		float2 l_727 = float2( l_726.r, l_726.g );
		float2 l_728 = l_727 * float2( 2, 2 );
		float2 l_729 = l_728 - float2( 1, 1 );
		float l_730 = g_flWaterRipplesIntensityA;
		float2 l_731 = l_729 * float2( l_730, l_730 );
		float3 l_732 = float3( l_731, l_726.b );
		float3 l_733 = float3( l_717, l_717, l_717 ) * l_732;
		float3 l_734 = float3( l_716, 0 ) + l_733;
		float4 l_735 = Tex2DS( g_tWaterCausticsAlphaA, g_sSampler0, l_734.xy );
		float l_736 = g_flWaterCausticsNoiseDisplacementB;
		float l_737 = g_flWaterRipplesScaleB;
		float3 l_738 = l_378 * float3( l_737, l_737, l_737 );
		float l_739 = g_flWaterRipplesRotationB;
		float3 l_740 = AxisDegrees( l_738, float3( 0, 0, 1 ), l_739 );
		float l_741 = g_flWaterRipplesSpeedB;
		float l_742 = g_flTime * l_741;
		float2 l_743 = float2( l_742, 0 );
		float2 l_744 = TileAndOffsetUv( l_740.xy, float2( 1, 1 ), l_743 );
		float4 l_745 = Tex2DS( g_tWaterRipplesNormalB, g_sSampler0, l_744 );
		float2 l_746 = float2( l_745.r, l_745.g );
		float2 l_747 = l_746 * float2( 2, 2 );
		float2 l_748 = l_747 - float2( 1, 1 );
		float l_749 = g_flWaterRipplesIntensityB;
		float2 l_750 = l_748 * float2( l_749, l_749 );
		float3 l_751 = float3( l_750, l_745.b );
		float3 l_752 = float3( l_736, l_736, l_736 ) * l_751;
		float l_753 = g_flWaterCausticsScaleB;
		float3 l_754 = l_378 * float3( l_753, l_753, l_753 );
		float l_755 = g_flWaterCausticsRotationB;
		float3 l_756 = AxisDegrees( l_754, float3( 0, 0, 1 ), l_755 );
		float l_757 = g_flWaterCausticsSpeedB;
		float l_758 = g_flTime * l_757;
		float2 l_759 = float2( l_758, 0 );
		float2 l_760 = TileAndOffsetUv( l_756.xy, float2( 1, 1 ), l_759 );
		float3 l_761 = l_752 + float3( l_760, 0 );
		float4 l_762 = Tex2DS( g_tWaterCausticsAlphaB, g_sSampler0, l_761.xy );
		float4 l_763 = l_735 + l_762;
		float4 l_764 = saturate( l_763 );
		float l_765 = g_flWaterCausticsAlphaValue;
		float4 l_766 = l_764 * float4( l_765, l_765, l_765, l_765 );
		float4 l_767 = ddx( l_766 );
		float l_768 = g_flWaterCausticsChromaticAberrationValue;
		float l_769 = 1 - l_768;
		float3 l_770 = float3( l_768, 0, l_769 );
		float4 l_771 = l_767 * float4( l_770, 0 );
		float4 l_772 = l_766 + l_771;
		float4 l_773 = saturate( lerp( l_708, l_772, l_766 ) );
		float4 l_774 = saturate( lerp( l_425, l_773, l_403 ) );
		float l_775 = l_199.z;
		float l_776 = g_flWeatherBlendSoftness;
		float l_777 = saturate( ( l_776 - 0.001 ) / ( 1 - 0.001 ) ) * ( 1 - 0 ) + 0;
		float l_778 = 2 * l_777;
		float l_779 = l_778 + 1;
		float l_780 = l_775 * l_779;
		float l_781 = l_780 - l_777;
		float l_782 = l_781 - l_777;
		float4 l_783 = l_376 - float4( l_782, l_782, l_782, l_782 );
		float4 l_784 = l_783 / float4( l_778, l_778, l_778, l_778 );
		float4 l_785 = saturate( l_784 );
		float4 l_786 = 1 - l_785;
		float4 l_787 = saturate( lerp( l_321, l_774, l_786 ) );
		float4 l_788 = g_vSurfacesEmissionBase;
		float4 l_789 = Tex2DS( g_tSurfacesEmissionMaskBase, g_sSampler0, l_0 );
		float4 l_790 = l_788 * l_789;
		float l_791 = g_flSurfacesEmissionBrightnessBase;
		float4 l_792 = l_790 * float4( l_791, l_791, l_791, l_791 );
		float4 l_793 = g_vSurfacesEmissionA;
		float4 l_794 = Tex2DS( g_tSurfacesEmissionMaskA, g_sSampler0, l_0 );
		float4 l_795 = l_793 * l_794;
		float l_796 = g_flSurfacesEmissionBrightnessA;
		float4 l_797 = l_795 * float4( l_796, l_796, l_796, l_796 );
		float4 l_798 = saturate( lerp( l_792, l_797, l_211 ) );
		float4 l_799 = g_vSurfacesEmissionB;
		float4 l_800 = Tex2DS( g_tSurfacesEmissionMaskB, g_sSampler0, l_0 );
		float4 l_801 = l_799 * l_800;
		float l_802 = g_flSurfacesEmissionBrightnessB;
		float4 l_803 = l_801 * float4( l_802, l_802, l_802, l_802 );
		float4 l_804 = saturate( lerp( l_798, l_803, l_320 ) );
		float4 l_805 = g_vWaterPuddlesEmission;
		float l_806 = g_flWaterPuddlesEmissionBrightness;
		float4 l_807 = l_805 * float4( l_806, l_806, l_806, l_806 );
		float l_808 = g_flWaterPuddlesEmissionBlendValue;
		float4 l_809 = saturate( lerp( l_804, min( 1.0f, (l_804) + (l_807) ), l_808 ) );
		float4 l_810 = saturate( lerp( l_804, Divide_blend( l_804, l_807 ), l_808 ) );
		float4 l_811 = saturate( lerp( l_804, max( 0.0f, (l_804) - (l_807) ), l_808 ) );
		float4 l_812 = saturate( lerp( l_804, (l_804) + (l_807) - 2.0f * (l_804) * (l_807), l_808 ) );
		float4 l_813 = saturate( lerp( l_804, abs( (l_804) - (l_807) ), l_808 ) );
		float4 l_814 = saturate( lerp( l_804, HardMix_blend( l_804, l_807 ), l_808 ) );
		float4 l_815 = saturate( lerp( l_804, LinearLight_blend( l_804, l_807 ), l_808 ) );
		float4 l_816 = saturate( lerp( l_804, VividLight_blend( l_804, l_807 ), l_808 ) );
		float4 l_817 = saturate( lerp( l_804, HardLight_blend( l_804, l_807 ), l_808 ) );
		float4 l_818 = saturate( lerp( l_804, SoftLight_blend( l_804, l_807 ), l_808 ) );
		float4 l_819 = saturate( lerp( l_804, Overlay_blend( l_804, l_807 ), l_808 ) );
		float4 l_820 = saturate( lerp( l_804, LinearDodge_blend( l_804, l_807 ), l_808 ) );
		float4 l_821 = saturate( lerp( l_804, ColorDodge_blend( l_804, l_807 ), l_808 ) );
		float4 l_822 = saturate( lerp( l_804, (l_804) + (l_807) - (l_804) * (l_807), l_808 ) );
		float4 l_823 = saturate( lerp( l_804, max( l_804, l_807 ), l_808 ) );
		float4 l_824 = saturate( lerp( l_804, LinearBurn_blend( l_804, l_807 ), l_808 ) );
		float4 l_825 = saturate( lerp( l_804, ColorBurn_blend( l_804, l_807 ), l_808 ) );
		float4 l_826 = saturate( lerp( l_804, l_804*l_807, l_808 ) );
		float4 l_827 = saturate( lerp( l_804, min( l_804, l_807 ), l_808 ) );
		float4 l_828 = saturate( lerp( l_804, l_807, l_808 ) );
		float l_829 = g_flWaterPuddlesEmissionBlendMode;
		float4 l_830 = l_829 > 0 ? l_828 : l_804;
		float4 l_831 = l_829 > 1 ? l_827 : l_830;
		float4 l_832 = l_829 > 2 ? l_826 : l_831;
		float4 l_833 = l_829 > 3 ? l_825 : l_832;
		float4 l_834 = l_829 > 4 ? l_824 : l_833;
		float4 l_835 = l_829 > 5 ? l_823 : l_834;
		float4 l_836 = l_829 > 6 ? l_822 : l_835;
		float4 l_837 = l_829 > 7 ? l_821 : l_836;
		float4 l_838 = l_829 > 8 ? l_820 : l_837;
		float4 l_839 = l_829 > 9 ? l_819 : l_838;
		float4 l_840 = l_829 > 10 ? l_818 : l_839;
		float4 l_841 = l_829 > 11 ? l_817 : l_840;
		float4 l_842 = l_829 > 12 ? l_816 : l_841;
		float4 l_843 = l_829 > 13 ? l_815 : l_842;
		float4 l_844 = l_829 > 14 ? l_814 : l_843;
		float4 l_845 = l_829 > 15 ? l_813 : l_844;
		float4 l_846 = l_829 > 16 ? l_812 : l_845;
		float4 l_847 = l_829 > 17 ? l_811 : l_846;
		float4 l_848 = l_829 > 18 ? l_810 : l_847;
		float4 l_849 = l_829 > 19 ? l_809 : l_848;
		float4 l_850 = saturate( lerp( l_804, l_849, l_403 ) );
		float4 l_851 = saturate( lerp( l_804, l_850, l_786 ) );
		float4 l_852 = Tex2DS( g_tSurfacesNormalBase, g_sSampler0, l_0 );
		float3 l_853 = DecodeNormal( l_852.xyz );
		float l_854 = l_853.y;
		float2 l_855 = float2( 0, l_854 );
		float l_856 = g_flSurfacesNormalIntensityBase;
		float2 l_857 = l_855 * float2( l_856, l_856 );
		float l_858 = l_853.z;
		float3 l_859 = float3( l_857, l_858 );
		float4 l_860 = Tex2DS( g_tSurfacesNormalA, g_sSampler0, l_0 );
		float3 l_861 = DecodeNormal( l_860.xyz );
		float l_862 = l_861.x;
		float l_863 = l_861.y;
		float2 l_864 = float2( l_862, l_863 );
		float l_865 = g_flSurfacesNormalIntensityA;
		float2 l_866 = l_864 * float2( l_865, l_865 );
		float l_867 = l_861.z;
		float3 l_868 = float3( l_866, l_867 );
		float3 l_869 = saturate( lerp( l_859, l_868, l_211.xyz ) );
		float4 l_870 = Tex2DS( g_tSurfacesNormalB, g_sSampler0, l_0 );
		float3 l_871 = DecodeNormal( l_870.xyz );
		float l_872 = l_871.y;
		float2 l_873 = float2( 0, l_872 );
		float l_874 = g_flSurfacesNormalIntensityB;
		float2 l_875 = l_873 * float2( l_874, l_874 );
		float l_876 = l_871.z;
		float3 l_877 = float3( l_875, l_876 );
		float3 l_878 = saturate( lerp( l_869, l_877, l_320.xyz ) );
		float4 l_879 = g_vWaterPuddlesNormal;
		float3 l_880 = Reoriented( l_878, l_879.xyz );
		float l_881 = g_flWaterPuddlesNormalBlendValue;
		float3 l_882 = lerp( l_878, l_880, l_881 );
		float3 l_883 = Whiteout( l_878, l_879.xyz );
		float3 l_884 = lerp( l_878, l_883, l_881 );
		float4 l_885 = lerp( float4( l_878, 0 ), l_879, l_881 );
		float l_886 = g_flWaterPuddlesNormalBlendMode;
		float4 l_887 = l_886 > 0 ? l_885 : float4( l_878, 0 );
		float4 l_888 = l_886 > 1 ? float4( l_884, 0 ) : l_887;
		float4 l_889 = l_886 > 2 ? float4( l_882, 0 ) : l_888;
		float4 l_890 = saturate( lerp( float4( l_878, 0 ), l_889, l_403 ) );
		float2 l_891 = float2( l_561.r, l_561.g );
		float2 l_892 = float2( l_586, l_586 ) * l_891;
		float l_893 = l_537.x;
		float l_894 = g_flRainRipplesIntensity;
		float l_895 = lerp( l_893, l_894, l_541.x );
		float2 l_896 = l_892 * float2( l_895, l_895 );
		float3 l_897 = float3( l_896, 1 );
		float4 l_898 = float4( 0, 0, 1, 1 );
		float4 l_899 = l_588 > 0 ? float4( l_897, 0 ) : l_898;
		float2 l_900 = float2( l_603.r, l_603.g );
		float2 l_901 = float2( l_625, l_625 ) * l_900;
		float2 l_902 = l_901 * float2( l_895, l_895 );
		float3 l_903 = float3( l_902, 1 );
		float3 l_904 = Reoriented( l_899.xyz, l_903 );
		float4 l_905 = l_588 > 1 ? float4( l_904, 0 ) : l_899;
		float2 l_906 = float2( l_641.r, l_641.g );
		float2 l_907 = float2( l_663, l_663 ) * l_906;
		float2 l_908 = l_907 * float2( l_895, l_895 );
		float3 l_909 = float3( l_908, 1 );
		float3 l_910 = Reoriented( l_905.xyz, l_909 );
		float4 l_911 = l_588 > 2 ? float4( l_910, 0 ) : l_905;
		float2 l_912 = float2( l_679.r, l_679.g );
		float2 l_913 = float2( l_701, l_701 ) * l_912;
		float2 l_914 = l_913 * float2( l_895, l_895 );
		float3 l_915 = float3( l_914, 1 );
		float3 l_916 = Reoriented( l_911.xyz, l_915 );
		float4 l_917 = l_588 > 3 ? float4( l_916, 0 ) : l_911;
		float3 l_918 = Whiteout( l_890.xyz, l_917.xyz );
		float3 l_919 = Reoriented( l_732, l_751 );
		float3 l_920 = Reoriented( l_919, l_917.xyz );
		float3 l_921 = Reoriented( l_890.xyz, l_920 );
		float3 l_922 = saturate( lerp( l_918, l_921, l_403.xyz ) );
		float3 l_923 = saturate( lerp( l_878, l_922, l_786.xyz ) );
		float4 l_924 = Tex2DS( g_tSurfacesRoughnessBase, g_sSampler0, l_0 );
		float4 l_925 = Tex2DS( g_tSurfacesRoughnessA, g_sSampler0, l_0 );
		float4 l_926 = saturate( lerp( l_924, l_925, l_211 ) );
		float4 l_927 = Tex2DS( g_tSurfacesRoughnessB, g_sSampler0, l_0 );
		float4 l_928 = saturate( lerp( l_926, l_927, l_320 ) );
		float l_929 = l_338.w;
		float4 l_930 = lerp( l_928, float4( l_929, l_929, l_929, l_929 ), l_405 );
		float l_931 = g_flWaterPuddlesRoughness;
		float l_932 = g_flWaterPuddlesRoughnessBlendValue;
		float4 l_933 = saturate( lerp( l_930, min( 1.0f, (l_930) + (float4( l_931, l_931, l_931, l_931 )) ), l_932 ) );
		float4 l_934 = saturate( lerp( l_930, Divide_blend( l_930, float4( l_931, l_931, l_931, l_931 ) ), l_932 ) );
		float4 l_935 = saturate( lerp( l_930, max( 0.0f, (l_930) - (float4( l_931, l_931, l_931, l_931 )) ), l_932 ) );
		float4 l_936 = saturate( lerp( l_930, (l_930) + (float4( l_931, l_931, l_931, l_931 )) - 2.0f * (l_930) * (float4( l_931, l_931, l_931, l_931 )), l_932 ) );
		float4 l_937 = saturate( lerp( l_930, abs( (l_930) - (float4( l_931, l_931, l_931, l_931 )) ), l_932 ) );
		float4 l_938 = saturate( lerp( l_930, HardMix_blend( l_930, float4( l_931, l_931, l_931, l_931 ) ), l_932 ) );
		float4 l_939 = saturate( lerp( l_930, LinearLight_blend( l_930, float4( l_931, l_931, l_931, l_931 ) ), l_932 ) );
		float4 l_940 = saturate( lerp( l_930, VividLight_blend( l_930, float4( l_931, l_931, l_931, l_931 ) ), l_932 ) );
		float4 l_941 = saturate( lerp( l_930, HardLight_blend( l_930, float4( l_931, l_931, l_931, l_931 ) ), l_932 ) );
		float4 l_942 = saturate( lerp( l_930, SoftLight_blend( l_930, float4( l_931, l_931, l_931, l_931 ) ), l_932 ) );
		float4 l_943 = saturate( lerp( l_930, Overlay_blend( l_930, float4( l_931, l_931, l_931, l_931 ) ), l_932 ) );
		float4 l_944 = saturate( lerp( l_930, LinearDodge_blend( l_930, float4( l_931, l_931, l_931, l_931 ) ), l_932 ) );
		float4 l_945 = saturate( lerp( l_930, ColorDodge_blend( l_930, float4( l_931, l_931, l_931, l_931 ) ), l_932 ) );
		float4 l_946 = saturate( lerp( l_930, (l_930) + (float4( l_931, l_931, l_931, l_931 )) - (l_930) * (float4( l_931, l_931, l_931, l_931 )), l_932 ) );
		float4 l_947 = saturate( lerp( l_930, max( l_930, float4( l_931, l_931, l_931, l_931 ) ), l_932 ) );
		float4 l_948 = saturate( lerp( l_930, LinearBurn_blend( l_930, float4( l_931, l_931, l_931, l_931 ) ), l_932 ) );
		float4 l_949 = saturate( lerp( l_930, ColorBurn_blend( l_930, float4( l_931, l_931, l_931, l_931 ) ), l_932 ) );
		float4 l_950 = saturate( lerp( l_930, l_930*float4( l_931, l_931, l_931, l_931 ), l_932 ) );
		float4 l_951 = saturate( lerp( l_930, min( l_930, float4( l_931, l_931, l_931, l_931 ) ), l_932 ) );
		float4 l_952 = saturate( lerp( l_930, float4( l_931, l_931, l_931, l_931 ), l_932 ) );
		float l_953 = g_flWaterPuddlesRoughnessBlendMode;
		float4 l_954 = l_953 > 0 ? l_952 : l_930;
		float4 l_955 = l_953 > 1 ? l_951 : l_954;
		float4 l_956 = l_953 > 2 ? l_950 : l_955;
		float4 l_957 = l_953 > 3 ? l_949 : l_956;
		float4 l_958 = l_953 > 4 ? l_948 : l_957;
		float4 l_959 = l_953 > 5 ? l_947 : l_958;
		float4 l_960 = l_953 > 6 ? l_946 : l_959;
		float4 l_961 = l_953 > 7 ? l_945 : l_960;
		float4 l_962 = l_953 > 8 ? l_944 : l_961;
		float4 l_963 = l_953 > 9 ? l_943 : l_962;
		float4 l_964 = l_953 > 10 ? l_942 : l_963;
		float4 l_965 = l_953 > 11 ? l_941 : l_964;
		float4 l_966 = l_953 > 12 ? l_940 : l_965;
		float4 l_967 = l_953 > 13 ? l_939 : l_966;
		float4 l_968 = l_953 > 14 ? l_938 : l_967;
		float4 l_969 = l_953 > 15 ? l_937 : l_968;
		float4 l_970 = l_953 > 16 ? l_936 : l_969;
		float4 l_971 = l_953 > 17 ? l_935 : l_970;
		float4 l_972 = l_953 > 18 ? l_934 : l_971;
		float4 l_973 = l_953 > 19 ? l_933 : l_972;
		float4 l_974 = saturate( lerp( l_930, l_973, l_403 ) );
		float l_975 = g_flRainRipplesRoughness;
		float l_976 = g_flRainRipplesRoughnessBlendValue;
		float4 l_977 = saturate( lerp( l_930, min( 1.0f, (l_930) + (float4( l_975, l_975, l_975, l_975 )) ), l_976 ) );
		float4 l_978 = saturate( lerp( l_930, Divide_blend( l_930, float4( l_975, l_975, l_975, l_975 ) ), l_976 ) );
		float4 l_979 = saturate( lerp( l_930, max( 0.0f, (l_930) - (float4( l_975, l_975, l_975, l_975 )) ), l_976 ) );
		float4 l_980 = saturate( lerp( l_930, (l_930) + (float4( l_975, l_975, l_975, l_975 )) - 2.0f * (l_930) * (float4( l_975, l_975, l_975, l_975 )), l_976 ) );
		float4 l_981 = saturate( lerp( l_930, abs( (l_930) - (float4( l_975, l_975, l_975, l_975 )) ), l_976 ) );
		float4 l_982 = saturate( lerp( l_930, HardMix_blend( l_930, float4( l_975, l_975, l_975, l_975 ) ), l_976 ) );
		float4 l_983 = saturate( lerp( l_930, LinearLight_blend( l_930, float4( l_975, l_975, l_975, l_975 ) ), l_976 ) );
		float4 l_984 = saturate( lerp( l_930, VividLight_blend( l_930, float4( l_975, l_975, l_975, l_975 ) ), l_976 ) );
		float4 l_985 = saturate( lerp( l_930, HardLight_blend( l_930, float4( l_975, l_975, l_975, l_975 ) ), l_976 ) );
		float4 l_986 = saturate( lerp( l_930, SoftLight_blend( l_930, float4( l_975, l_975, l_975, l_975 ) ), l_976 ) );
		float4 l_987 = saturate( lerp( l_930, Overlay_blend( l_930, float4( l_975, l_975, l_975, l_975 ) ), l_976 ) );
		float4 l_988 = saturate( lerp( l_930, LinearDodge_blend( l_930, float4( l_975, l_975, l_975, l_975 ) ), l_976 ) );
		float4 l_989 = saturate( lerp( l_930, ColorDodge_blend( l_930, float4( l_975, l_975, l_975, l_975 ) ), l_976 ) );
		float4 l_990 = saturate( lerp( l_930, (l_930) + (float4( l_975, l_975, l_975, l_975 )) - (l_930) * (float4( l_975, l_975, l_975, l_975 )), l_976 ) );
		float4 l_991 = saturate( lerp( l_930, max( l_930, float4( l_975, l_975, l_975, l_975 ) ), l_976 ) );
		float4 l_992 = saturate( lerp( l_930, LinearBurn_blend( l_930, float4( l_975, l_975, l_975, l_975 ) ), l_976 ) );
		float4 l_993 = saturate( lerp( l_930, ColorBurn_blend( l_930, float4( l_975, l_975, l_975, l_975 ) ), l_976 ) );
		float4 l_994 = saturate( lerp( l_930, l_930*float4( l_975, l_975, l_975, l_975 ), l_976 ) );
		float4 l_995 = saturate( lerp( l_930, min( l_930, float4( l_975, l_975, l_975, l_975 ) ), l_976 ) );
		float4 l_996 = saturate( lerp( l_930, float4( l_975, l_975, l_975, l_975 ), l_976 ) );
		float l_997 = g_flRainRipplesRoughnessBlendMode;
		float4 l_998 = l_997 > 0 ? l_996 : l_930;
		float4 l_999 = l_997 > 1 ? l_995 : l_998;
		float4 l_1000 = l_997 > 2 ? l_994 : l_999;
		float4 l_1001 = l_997 > 3 ? l_993 : l_1000;
		float4 l_1002 = l_997 > 4 ? l_992 : l_1001;
		float4 l_1003 = l_997 > 5 ? l_991 : l_1002;
		float4 l_1004 = l_997 > 6 ? l_990 : l_1003;
		float4 l_1005 = l_997 > 7 ? l_989 : l_1004;
		float4 l_1006 = l_997 > 8 ? l_988 : l_1005;
		float4 l_1007 = l_997 > 9 ? l_987 : l_1006;
		float4 l_1008 = l_997 > 10 ? l_986 : l_1007;
		float4 l_1009 = l_997 > 11 ? l_985 : l_1008;
		float4 l_1010 = l_997 > 12 ? l_984 : l_1009;
		float4 l_1011 = l_997 > 13 ? l_983 : l_1010;
		float4 l_1012 = l_997 > 14 ? l_982 : l_1011;
		float4 l_1013 = l_997 > 15 ? l_981 : l_1012;
		float4 l_1014 = l_997 > 16 ? l_980 : l_1013;
		float4 l_1015 = l_997 > 17 ? l_979 : l_1014;
		float4 l_1016 = l_997 > 18 ? l_978 : l_1015;
		float4 l_1017 = l_997 > 19 ? l_977 : l_1016;
		float4 l_1018 = saturate( lerp( l_930, l_1017, l_704 ) );
		float4 l_1019 = saturate( lerp( l_974, l_1018, l_707 ) );
		float4 l_1020 = saturate( lerp( l_930, l_1019, l_403 ) );
		float4 l_1021 = saturate( lerp( l_928, l_1020, l_786 ) );
		float4 l_1022 = saturate( lerp( l_407, l_412, l_211 ) );
		float4 l_1023 = saturate( lerp( l_1022, l_418, l_320 ) );
		float l_1024 = g_flWaterPuddlesMetalness;
		float l_1025 = g_flWaterPuddlesMetalnessBlendValue;
		float4 l_1026 = saturate( lerp( l_1023, min( 1.0f, (l_1023) + (float4( l_1024, l_1024, l_1024, l_1024 )) ), l_1025 ) );
		float4 l_1027 = saturate( lerp( l_1023, Divide_blend( l_1023, float4( l_1024, l_1024, l_1024, l_1024 ) ), l_1025 ) );
		float4 l_1028 = saturate( lerp( l_1023, max( 0.0f, (l_1023) - (float4( l_1024, l_1024, l_1024, l_1024 )) ), l_1025 ) );
		float4 l_1029 = saturate( lerp( l_1023, (l_1023) + (float4( l_1024, l_1024, l_1024, l_1024 )) - 2.0f * (l_1023) * (float4( l_1024, l_1024, l_1024, l_1024 )), l_1025 ) );
		float4 l_1030 = saturate( lerp( l_1023, abs( (l_1023) - (float4( l_1024, l_1024, l_1024, l_1024 )) ), l_1025 ) );
		float4 l_1031 = saturate( lerp( l_1023, HardMix_blend( l_1023, float4( l_1024, l_1024, l_1024, l_1024 ) ), l_1025 ) );
		float4 l_1032 = saturate( lerp( l_1023, LinearLight_blend( l_1023, float4( l_1024, l_1024, l_1024, l_1024 ) ), l_1025 ) );
		float4 l_1033 = saturate( lerp( l_1023, VividLight_blend( l_1023, float4( l_1024, l_1024, l_1024, l_1024 ) ), l_1025 ) );
		float4 l_1034 = saturate( lerp( l_1023, HardLight_blend( l_1023, float4( l_1024, l_1024, l_1024, l_1024 ) ), l_1025 ) );
		float4 l_1035 = saturate( lerp( l_1023, SoftLight_blend( l_1023, float4( l_1024, l_1024, l_1024, l_1024 ) ), l_1025 ) );
		float4 l_1036 = saturate( lerp( l_1023, Overlay_blend( l_1023, float4( l_1024, l_1024, l_1024, l_1024 ) ), l_1025 ) );
		float4 l_1037 = saturate( lerp( l_1023, LinearDodge_blend( l_1023, float4( l_1024, l_1024, l_1024, l_1024 ) ), l_1025 ) );
		float4 l_1038 = saturate( lerp( l_1023, ColorDodge_blend( l_1023, float4( l_1024, l_1024, l_1024, l_1024 ) ), l_1025 ) );
		float4 l_1039 = saturate( lerp( l_1023, (l_1023) + (float4( l_1024, l_1024, l_1024, l_1024 )) - (l_1023) * (float4( l_1024, l_1024, l_1024, l_1024 )), l_1025 ) );
		float4 l_1040 = saturate( lerp( l_1023, max( l_1023, float4( l_1024, l_1024, l_1024, l_1024 ) ), l_1025 ) );
		float4 l_1041 = saturate( lerp( l_1023, LinearBurn_blend( l_1023, float4( l_1024, l_1024, l_1024, l_1024 ) ), l_1025 ) );
		float4 l_1042 = saturate( lerp( l_1023, ColorBurn_blend( l_1023, float4( l_1024, l_1024, l_1024, l_1024 ) ), l_1025 ) );
		float4 l_1043 = saturate( lerp( l_1023, l_1023*float4( l_1024, l_1024, l_1024, l_1024 ), l_1025 ) );
		float4 l_1044 = saturate( lerp( l_1023, min( l_1023, float4( l_1024, l_1024, l_1024, l_1024 ) ), l_1025 ) );
		float4 l_1045 = saturate( lerp( l_1023, float4( l_1024, l_1024, l_1024, l_1024 ), l_1025 ) );
		float l_1046 = g_flWaterPuddlesMetalnessBlendMode;
		float4 l_1047 = l_1046 > 0 ? l_1045 : l_1023;
		float4 l_1048 = l_1046 > 1 ? l_1044 : l_1047;
		float4 l_1049 = l_1046 > 2 ? l_1043 : l_1048;
		float4 l_1050 = l_1046 > 3 ? l_1042 : l_1049;
		float4 l_1051 = l_1046 > 4 ? l_1041 : l_1050;
		float4 l_1052 = l_1046 > 5 ? l_1040 : l_1051;
		float4 l_1053 = l_1046 > 6 ? l_1039 : l_1052;
		float4 l_1054 = l_1046 > 7 ? l_1038 : l_1053;
		float4 l_1055 = l_1046 > 8 ? l_1037 : l_1054;
		float4 l_1056 = l_1046 > 9 ? l_1036 : l_1055;
		float4 l_1057 = l_1046 > 10 ? l_1035 : l_1056;
		float4 l_1058 = l_1046 > 11 ? l_1034 : l_1057;
		float4 l_1059 = l_1046 > 12 ? l_1033 : l_1058;
		float4 l_1060 = l_1046 > 13 ? l_1032 : l_1059;
		float4 l_1061 = l_1046 > 14 ? l_1031 : l_1060;
		float4 l_1062 = l_1046 > 15 ? l_1030 : l_1061;
		float4 l_1063 = l_1046 > 16 ? l_1029 : l_1062;
		float4 l_1064 = l_1046 > 17 ? l_1028 : l_1063;
		float4 l_1065 = l_1046 > 18 ? l_1027 : l_1064;
		float4 l_1066 = l_1046 > 19 ? l_1026 : l_1065;
		float4 l_1067 = saturate( lerp( l_1023, l_1066, l_403 ) );
		float4 l_1068 = saturate( lerp( l_1023, l_1067, l_786 ) );
		float4 l_1069 = saturate( lerp( l_346, l_355, l_211 ) );
		float4 l_1070 = saturate( lerp( l_1069, l_365, l_320 ) );
		float l_1071 = g_flWaterPuddlesAmbientOcclusion;
		float l_1072 = g_flWaterPuddlesAmbientOcclusionBlendValue;
		float4 l_1073 = saturate( lerp( l_1070, min( 1.0f, (l_1070) + (float4( l_1071, l_1071, l_1071, l_1071 )) ), l_1072 ) );
		float4 l_1074 = saturate( lerp( l_1070, Divide_blend( l_1070, float4( l_1071, l_1071, l_1071, l_1071 ) ), l_1072 ) );
		float4 l_1075 = saturate( lerp( l_1070, max( 0.0f, (l_1070) - (float4( l_1071, l_1071, l_1071, l_1071 )) ), l_1072 ) );
		float4 l_1076 = saturate( lerp( l_1070, (l_1070) + (float4( l_1071, l_1071, l_1071, l_1071 )) - 2.0f * (l_1070) * (float4( l_1071, l_1071, l_1071, l_1071 )), l_1072 ) );
		float4 l_1077 = saturate( lerp( l_1070, abs( (l_1070) - (float4( l_1071, l_1071, l_1071, l_1071 )) ), l_1072 ) );
		float4 l_1078 = saturate( lerp( l_1070, HardMix_blend( l_1070, float4( l_1071, l_1071, l_1071, l_1071 ) ), l_1072 ) );
		float4 l_1079 = saturate( lerp( l_1070, LinearLight_blend( l_1070, float4( l_1071, l_1071, l_1071, l_1071 ) ), l_1072 ) );
		float4 l_1080 = saturate( lerp( l_1070, VividLight_blend( l_1070, float4( l_1071, l_1071, l_1071, l_1071 ) ), l_1072 ) );
		float4 l_1081 = saturate( lerp( l_1070, HardLight_blend( l_1070, float4( l_1071, l_1071, l_1071, l_1071 ) ), l_1072 ) );
		float4 l_1082 = saturate( lerp( l_1070, SoftLight_blend( l_1070, float4( l_1071, l_1071, l_1071, l_1071 ) ), l_1072 ) );
		float4 l_1083 = saturate( lerp( l_1070, Overlay_blend( l_1070, float4( l_1071, l_1071, l_1071, l_1071 ) ), l_1072 ) );
		float4 l_1084 = saturate( lerp( l_1070, LinearDodge_blend( l_1070, float4( l_1071, l_1071, l_1071, l_1071 ) ), l_1072 ) );
		float4 l_1085 = saturate( lerp( l_1070, ColorDodge_blend( l_1070, float4( l_1071, l_1071, l_1071, l_1071 ) ), l_1072 ) );
		float4 l_1086 = saturate( lerp( l_1070, (l_1070) + (float4( l_1071, l_1071, l_1071, l_1071 )) - (l_1070) * (float4( l_1071, l_1071, l_1071, l_1071 )), l_1072 ) );
		float4 l_1087 = saturate( lerp( l_1070, max( l_1070, float4( l_1071, l_1071, l_1071, l_1071 ) ), l_1072 ) );
		float4 l_1088 = saturate( lerp( l_1070, LinearBurn_blend( l_1070, float4( l_1071, l_1071, l_1071, l_1071 ) ), l_1072 ) );
		float4 l_1089 = saturate( lerp( l_1070, ColorBurn_blend( l_1070, float4( l_1071, l_1071, l_1071, l_1071 ) ), l_1072 ) );
		float4 l_1090 = saturate( lerp( l_1070, l_1070*float4( l_1071, l_1071, l_1071, l_1071 ), l_1072 ) );
		float4 l_1091 = saturate( lerp( l_1070, min( l_1070, float4( l_1071, l_1071, l_1071, l_1071 ) ), l_1072 ) );
		float4 l_1092 = saturate( lerp( l_1070, float4( l_1071, l_1071, l_1071, l_1071 ), l_1072 ) );
		float l_1093 = g_flWaterPuddlesAmbientOcclusionBlendMode;
		float4 l_1094 = l_1093 > 0 ? l_1092 : l_1070;
		float4 l_1095 = l_1093 > 1 ? l_1091 : l_1094;
		float4 l_1096 = l_1093 > 2 ? l_1090 : l_1095;
		float4 l_1097 = l_1093 > 3 ? l_1089 : l_1096;
		float4 l_1098 = l_1093 > 4 ? l_1088 : l_1097;
		float4 l_1099 = l_1093 > 5 ? l_1087 : l_1098;
		float4 l_1100 = l_1093 > 6 ? l_1086 : l_1099;
		float4 l_1101 = l_1093 > 7 ? l_1085 : l_1100;
		float4 l_1102 = l_1093 > 8 ? l_1084 : l_1101;
		float4 l_1103 = l_1093 > 9 ? l_1083 : l_1102;
		float4 l_1104 = l_1093 > 10 ? l_1082 : l_1103;
		float4 l_1105 = l_1093 > 11 ? l_1081 : l_1104;
		float4 l_1106 = l_1093 > 12 ? l_1080 : l_1105;
		float4 l_1107 = l_1093 > 13 ? l_1079 : l_1106;
		float4 l_1108 = l_1093 > 14 ? l_1078 : l_1107;
		float4 l_1109 = l_1093 > 15 ? l_1077 : l_1108;
		float4 l_1110 = l_1093 > 16 ? l_1076 : l_1109;
		float4 l_1111 = l_1093 > 17 ? l_1075 : l_1110;
		float4 l_1112 = l_1093 > 18 ? l_1074 : l_1111;
		float4 l_1113 = l_1093 > 19 ? l_1073 : l_1112;
		float4 l_1114 = saturate( lerp( l_1070, l_1113, l_403 ) );
		float4 l_1115 = saturate( lerp( l_1070, l_1114, l_786 ) );
		
		m.Albedo = l_787.xyz;
		m.Emission = l_851.xyz;
		m.Opacity = 1;
		m.Normal = l_923;
		m.Roughness = l_1021.x;
		m.Metalness = l_1068.x;
		m.AmbientOcclusion = l_1115.x;
		
		
		m.AmbientOcclusion = saturate( m.AmbientOcclusion );
		m.Roughness = saturate( m.Roughness );
		m.Metalness = saturate( m.Metalness );
		m.Opacity = saturate( m.Opacity );
		
		// Result node takes normal as tangent space, convert it to world space now
		m.Normal = TransformNormal( m.Normal, i.vNormalWs, i.vTangentUWs, i.vTangentVWs );
		
		// for some toolvis shit
		m.WorldTangentU = i.vTangentUWs;
		m.WorldTangentV = i.vTangentVWs;
		m.TextureCoords = i.vTextureCoords.xy;
				
		return ShadingModelStandard::Shade( i, m );
	}
}
