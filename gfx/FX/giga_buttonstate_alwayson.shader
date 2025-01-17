Includes = {
	"buttonstate.fxh"
	"sprite_animation.fxh"
	"text.fxh"
}


PixelShader =
{
	Samplers =
	{
		MapTexture =
		{
			Index = 0
			MagFilter = "Linear"
			MinFilter = "Linear"
			MipFilter = "None"
			AddressU = "Wrap"
			AddressV = "Wrap"
		}
		MaskTexture =
		{
			Index = 1
			MagFilter = "Linear"
			MinFilter = "Linear"
			MipFilter = "None"
			AddressU = "Clamp"
			AddressV = "Clamp"
		}
		AnimatedTexture =
		{
			Index = 2
			MagFilter = "Linear"
			MinFilter = "Linear"
			MipFilter = "None"
			AddressU = "Wrap"
			AddressV = "Wrap"
		}
		MaskTexture2 =
		{
			Index = 3
			MagFilter = "Linear"
			MinFilter = "Linear"
			MipFilter = "None"
			AddressU = "Clamp"
			AddressV = "Clamp"
		}
		AnimatedTexture2 =
		{
			Index = 4
			MagFilter = "Linear"
			MinFilter = "Linear"
			MipFilter = "None"
			AddressU = "Wrap"
			AddressV = "Wrap"
		}
	}
}


VertexStruct VS_OUTPUT
{
	float4  vPosition : PDX_POSITION;
	float2  vTexCoord : TEXCOORD0;
@ifdef ANIMATED
	float4  vAnimatedTexCoord : TEXCOORD1;
@endif
};


VertexShader =
{
	MainCode VertexShader
		ConstantBuffers = { Common, SpriteAnimation }
	[[
		VS_OUTPUT main(const VS_INPUT v )
		{
		    VS_OUTPUT Out;
		    Out.vPosition  = mul( WorldViewProjectionMatrix, float4( v.vPosition.xyz, 1 ) );

		    Out.vTexCoord = v.vTexCoord;
			Out.vTexCoord += Offset;

		#ifdef ANIMATED
			Out.vAnimatedTexCoord = GetAnimatedTexcoord(v.vTexCoord);
		#endif

		    return Out;
		}
	]]

	MainCode VertexShaderText
		ConstantBuffers = { TextVertex }
	[[
		VS_DEFAULT_TEXT_OUTPUT main( VS_DEFAULT_TEXT_INPUT v )
		{
			return DefaultTextVertexShader( v );
		}
	]]
}

PixelShader =
{
	MainCode PixelShaderUp
		ConstantBuffers = { Common, SpriteAnimation }
	[[
		float4 main( VS_OUTPUT v ) : PDX_COLOR
		{
		    float4 OutColor = tex2D( MapTexture, v.vTexCoord );

		#ifdef ANIMATED
			OutColor = Animate(OutColor, v.vTexCoord, v.vAnimatedTexCoord, MaskTexture, AnimatedTexture, MaskTexture2, AnimatedTexture2);
		#endif

			OutColor *= Color;
			return OutColor;
		}
	]]

	MainCode PixelShaderDisable
		ConstantBuffers = { Common, SpriteAnimation }
	[[
		float4 main( VS_OUTPUT v ) : PDX_COLOR
		{
		    float4 OutColor = tex2D( MapTexture, v.vTexCoord );
		    float Grey = dot( OutColor.rgb, float3( 0.212671f, 0.715160f, 0.072169f ) );
		    OutColor.rgb = float3(Grey, Grey, Grey);
			OutColor *= Color;
		    return OutColor;
		}
	]]

	MainCode PixelShaderText
		ConstantBuffers = { TextPixel }
	[[
		float4 main( VS_DEFAULT_TEXT_OUTPUT v ) : PDX_COLOR
		{
			float4 OutColor = DefaultTextPixelShader( v, MapTexture );

			#ifdef DISABLED
				float Grey = dot( OutColor.rgb, float3( 0.212671f, 0.715160f, 0.072169f ) );
				Grey = pow( Grey, 2 );
			    OutColor.rgb = float3(Grey, Grey, Grey);
			#endif

		    return OutColor;
		}
	]]
}


BlendState BlendState
{
	BlendEnable = yes
	SourceBlend = "src_alpha"
	DestBlend = "inv_src_alpha"
}


Effect Up
{
	VertexShader = "VertexShader"
	PixelShader = "PixelShaderUp"
}

Effect Down
{
	VertexShader = "VertexShader"
	PixelShader = "PixelShaderUp"
}

Effect Disable
{
	VertexShader = "VertexShader"
	PixelShader = "PixelShaderUp" #//Disable
}

Effect Over
{
	VertexShader = "VertexShader"
	PixelShader = "PixelShaderUp"
}

Effect TextUp
{
	VertexShader = "VertexShaderText"
	PixelShader = "PixelShaderText"
}

Effect TextDown
{
	VertexShader = "VertexShaderText"
	PixelShader = "PixelShaderText"
}

Effect TextDisable
{
	VertexShader = "VertexShaderText"
	PixelShader = "PixelShaderText"
	#//Defines = { "DISABLED" }
}

Effect TextOver
{
	VertexShader = "VertexShaderText"
	PixelShader = "PixelShaderText"
}
