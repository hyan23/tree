// GenDescriptor.h
// Author: hyan23
// Date: 2016.06.02
//

#pragma once

#include "resource.h" // 主符号

class CGenDescriptorApp : public CWinApp {
public:
	CGenDescriptorApp(void);

public:
	virtual BOOL InitInstance(void);
	DECLARE_MESSAGE_MAP()
};

extern CGenDescriptorApp theApp;
